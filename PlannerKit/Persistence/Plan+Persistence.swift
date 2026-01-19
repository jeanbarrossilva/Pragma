// ===-------------------------------------------------------------------------------------------===
// Copyright © 2026 Jean Silva
//
// This file is part of the Pragma open-source project.
//
// This program is free software: you can redistribute it and/or modify it under the terms of the
// GNU General Public License as published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
// even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
// General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with this program. If
// not, see https://www.gnu.org/licenses.
// ===-------------------------------------------------------------------------------------------===

import CoreData

extension Planning {
  /// Alias for the initialization of a ``PlanRepository``.
  static func makeRepository() async -> PlannerRepository { await PlannerRepository() }
}

/// Abstraction for accessing a container in which ``CorePlanner``-related structures are persisted,
/// with the stored data being retrievable after deinitialization of this class or implementations
/// of ``CorePlanner/Plan``, ``CorePlanner/Goal`` and ``CorePlanner/ToDo``.
public class PlannerRepository {
  /// Storage of plans, goals and to-dos.
  private let container: NSPersistentContainer

  /// Privately-queued context in which plans are persisted.
  ///
  /// This context is exclusively for plans. Each goal adds its to-dos in its own context, and each
  /// to-do gets updated in one of their own; contexts are given per entity, and every insertion of
  /// a plan done by ``addPlan(titled:describedAs:)`` occurs in this one.
  private let context: NSManagedObjectContext

  fileprivate init() async {
    self.container = .init(name: "Planner")
    self.context = container.newBackgroundContext()
    await withCheckedContinuation { continuation in
      self.container.loadPersistentStores { description, error in
        if let error { fatalError(error.localizedDescription) }
        continuation.resume()
      }
    }
  }

  /// Persists a plan without goals into the underlying container.
  ///
  /// - Parameters:
  ///   - title: ``CorePlanner/Headlineable/title`` of the plan.
  ///   - description: ``CorePlanner/Headlineable/description`` of the plan.
  /// - Returns: The ID of the added plan.
  public func addPlan(
    titled title: String,
    describedAs description: String
  ) async throws -> some Plan {
    let planID = try await context.insert(PlanEntity.self) { entity in
      entity.title = title
      entity.planDescription = description
    }
    return try await PersistedPlan(container: container, id: planID)
  }
}

/// Plan persisted into a container by a ``PlannerRepository``.
private struct PersistedPlan: Plan, PersistedDomain {
  typealias BackingObject = PlanEntity

  let container: NSPersistentContainer
  let context: NSManagedObjectContext
  let id: NSManagedObjectID
  var title: String
  var description: String

  private(set) var goals = [PersistedGoal]()

  static let description = "plan"
  static let descriptionKey = "planDescription"

  init(container: NSPersistentContainer, id: NSManagedObjectID) async throws(PersistenceError) {
    self.container = container
    self.context = container.newBackgroundContext()
    self.id = id
    self.title = try await Self.normalizeTitle(of: id, in: context)
    self.description = try await Self.normalizeDescription(of: id, in: context)
  }

  mutating func addGoal(
    titled title: String,
    describedAs description: String
  ) async throws(PersistenceError) -> PersistedGoal {
    let backingObjectSnapshot = Snapshot(of: try await backingObject(as: PlanEntity.self))
    let goalID = try await context.insert(GoalEntity.self) { entity in
      entity.plan = backingObjectSnapshot.copy()
      entity.title = title
      entity.goalDescription = description
    }
    let goal = try await PersistedGoal(container: container, id: goalID)
    goals.append(goal)
    return goal
  }

  func removeGoal(identifiedAs id: NSManagedObjectID) async throws(PersistenceError) {
    try await context.delete(with: id)
  }
}

/// Goal persisted into a container by its ``PersistedPlan``.
private struct PersistedGoal: Goal, PersistedDomain {
  let container: NSPersistentContainer
  let context: NSManagedObjectContext
  let id: NSManagedObjectID
  var title: String
  var description: String

  private(set) var toDos = [PersistedToDo]()

  static let description = "goal"
  static let descriptionKey = "goalDescription"

  init(container: NSPersistentContainer, id: NSManagedObjectID) async throws(PersistenceError) {
    self.container = container
    self.context = container.newBackgroundContext()
    self.id = id
    self.title = try await Self.normalizeTitle(of: id, in: context)
    self.description = try await Self.normalizeDescription(of: id, in: context)
  }

  mutating func addToDo(
    titled title: String,
    describedAs description: String,
    due deadline: Date
  ) async throws(PersistenceError) -> PersistedToDo {
    let backingObjectSnapshot = Snapshot(of: try await backingObject(as: GoalEntity.self))
    let toDoID = try await context.insert(ToDoEntity.self) { entity in
      entity.goal = backingObjectSnapshot.copy()
      entity.title = title
      entity.toDoDescription = description
    }
    let toDo = try await PersistedToDo(container: container, id: toDoID)
    toDos.append(toDo)
    return toDo
  }

  func removeToDo(identifiedAs id: NSManagedObjectID) async throws(PersistenceError) {
    try await context.delete(with: id)
  }
}

/// To-do persisted into a container by its ``PersistedGoal``.
private struct PersistedToDo: ToDo, PersistedDomain {
  let container: NSPersistentContainer
  let context: NSManagedObjectContext
  let id: NSManagedObjectID
  var title: String
  var description: String
  private(set) var status: Status
  private(set) var deadline: Date

  static let description = "to-do"
  static let descriptionKey = "toDoDescription"

  init(container: NSPersistentContainer, id: NSManagedObjectID) async throws(PersistenceError) {
    self.container = container
    self.context = container.newBackgroundContext()
    self.id = id
    self.title = try await Self.normalizeTitle(of: id, in: context)
    self.description = try await Self.normalizeDescription(of: id, in: context)
    let backingObject = try await context.object(with: id, as: ToDoEntity.self)
    self.status = Status.allCases[.init(backingObject.status)]
    self.deadline = try require(\.deadline, keyed: "deadline", in: backingObject)
  }

  mutating func setStatus(to newStatus: Status) async throws(PersistenceError) {
    try await context.update(with: id) { (backingObject: ToDoEntity) in
      backingObject.status = .init(Status.allCases.firstIndex(of: newStatus) ?? 0)
    }
    status = newStatus
  }

  mutating func setDeadline(to newDeadline: Date) async throws(PersistenceError) {
    try await context.update(with: id) { (backingObject: ToDoEntity) in
      backingObject.deadline = newDeadline
    }
    deadline = newDeadline
  }
}

/// Interface common to ``CorePlanner`` structures supporting persistence backed by the CoreData
/// framework.
private protocol PersistedDomain: Headlineable where ID: NSManagedObjectID {
  /// Container into which the ``backingObject`` is persisted.
  var container: NSPersistentContainer { get }

  /// Privately-queued context in which every read/write operation occurs.
  var context: NSManagedObjectContext { get }

  var title: String { get set }
  var description: String { get set }

  /// Name of the property of the ``backingObject`` storing the ``description``.
  ///
  /// - SeeAlso: ``titleKey``
  static var descriptionKey: String { get }
}

extension PersistedDomain where Self: Headlineable {
  /// Name of the property of the ``backingObject`` storing the ``title``.
  ///
  /// - SeeAlso: ``descriptionKey``
  fileprivate static var titleKey: String { "title" }

  fileprivate mutating func setTitle(to newTitle: String) async throws(PersistenceError) {
    try await backingObject(as: NSManagedObject.self).setValue(newTitle, forKey: Self.titleKey)
    title = try await Self.normalizeTitle(of: id, in: context)
  }

  fileprivate mutating func setDescription(to newDescription: String) async throws(PersistenceError)
  {
    try await backingObject(as: NSManagedObject.self).setValue(
      newDescription,
      forKey: Self.descriptionKey
    )
    description = try await Self.normalizeDescription(of: id, in: context)
  }

  // Ideally, there would be a single function for normalizing both the title and the description of
  // an NSManagedObject; however, an object of such type also conforms to StringCustomConvertible,
  // which mandates that conforming types provide a getter for `description`, the textual
  // representation of the instance.
  //
  // Maybe `Headlined/description` should be renamed (to "abstract", or "overview"?):
  // CustomStringConvertible is a Swift-defined type, and its description and that of a headline are
  // semantically incompatible.

  /// Updates the title of an object, replacing its current one by the version normalized by this
  /// type of headlineable. This function assumes that the object passed into it contains a
  /// property named "title" which stores the title suggested for the object.
  ///
  /// - Parameters:
  ///   - objectID: ID of the object whose title will be normalized.
  ///   - context: Context in which the normalization will occur.
  /// - Returns: The normalized title.
  fileprivate static func normalizeTitle(
    of objectID: NSManagedObjectID,
    in context: NSManagedObjectContext
  ) async throws(PersistenceError) -> String {
    try await context.update(with: objectID) { object throws(PersistenceError) in
      var title = try require(
        object.value(forKey: Self.titleKey) as? String,
        keyed: Self.titleKey,
        in: object
      )
      normalize(title: &title)
      object.setValue(title, forKey: Self.titleKey)
      return title
    }
  }

  /// Updates the description of an object, replacing its current one by the version normalized by
  /// this type of headlineable. This function assumes that the object passed into it contains a
  /// property whose name is the same as ``descriptionKey``, in which the description suggested for
  /// the object is stored.
  ///
  /// - Parameters:
  ///   - objectID: ID of the object whose description will be normalized.
  ///   - context: Context in which the normalization will occur.
  /// - Returns: The normalized description.
  fileprivate static func normalizeDescription(
    of objectID: NSManagedObjectID,
    in context: NSManagedObjectContext
  ) async throws(PersistenceError) -> String {
    try await context.update(with: objectID) { object throws(PersistenceError) in
      var description = try require(
        object.value(forKey: descriptionKey) as? String,
        keyed: descriptionKey,
        in: object
      )
      Self.normalize(description: &description)
      object.setValue(description, forKey: descriptionKey)
      return description
    }
  }
}

extension PersistedDomain {
  /// Retrieves the object persisted into the ``container`` and on which the headline of this
  /// implementation is based.
  ///
  /// - Parameter type: Type of subclass of `NSManagedObject` expected to be that of the retrieved
  ///   object. Failure to cast a found object to this type by this function results in an error
  ///   being thrown.
  fileprivate func backingObject<BackingObject>(
    as type: BackingObject.Type
  ) async throws(PersistenceError) -> BackingObject where BackingObject: NSManagedObject {
    try await context.object(with: id, as: BackingObject.self)
  }
}

extension NSManagedObjectContext {
  /// Execute-around method for creating a new background context in which an instance of an object
  /// of the given type may be changed, with these changes being automatically saved afterward.
  ///
  /// - Parameters:
  ///   - objectType: Type of the object to be saved into the newly created background context.
  ///   - change: Closure intended to perform any desired changes on the initialized object in the
  ///     background when called. Because the object was initialized in the created background
  ///     context, the value assigned to the `managedObjectContext` property of the object is equal
  ///     to such context. Changes are saved immediately after the call to this closure.
  /// - Returns: A copy of the inserted object.
  fileprivate func insert<Object>(
    _ objectType: Object.Type,
    _ change: @escaping @Sendable (Object) throws(PersistenceError) -> Void
  ) async throws(PersistenceError) -> NSManagedObjectID where Object: NSManagedObject {
    try await performWithTypedThrowsCastToPersistenceError { [self] in
      let object = Object(context: self)
      try change(object)
      if hasChanges { try save() }
      return object.objectID
    }
  }

  /// Updates the object identified with the given ID in the background, saving the newly created
  /// context afterward. Similar to ``insert(_:_:)``, differing from it in that this function is
  /// aimed toward changing and saving existing objects.
  ///
  /// - Parameters:
  ///   - id: ID of the persisted object to be updated.
  ///   - update: Closure intended to update the object, now in the new, ephemeral context.
  fileprivate func update<Object, Result>(
    with id: NSManagedObjectID,
    _ update: @escaping @Sendable (Object) throws(PersistenceError) -> Result
  ) async throws(PersistenceError) -> Result where Object: NSManagedObject, Result: Sendable {
    return try await performWithTypedThrowsCastToPersistenceError { [self] in
      let object = try object(with: id, as: Object.self)
      let result = try update(object)
      if hasChanges { try save() }
      return result
    }
  }

  /// Deletes the object whose stable ID is the given one.
  ///
  /// - Parameter id: ID of the object to be retrieved, as generated by CoreData.
  fileprivate func delete(with id: NSManagedObjectID) async throws(PersistenceError) {
    try await performWithTypedThrowsCastToPersistenceError { [self] in
      let object = try object(with: id, as: NSManagedObject.self)
      delete(object)
      if hasChanges { try save() }
    }
  }

  /// Retrieves the object saved with the given ID.
  ///
  /// Differs from ``object(with:)`` in that no object is returned in case none is identified with
  /// the ID or exists but is of a type which is not the one specified to this function: faults
  /// (placeholder objects for when an object with some ID was not found) are treated as errors
  /// by this function.
  ///
  /// - Parameters:
  ///   - id: ID of the object to be retrieved, as generated by CoreData.
  ///   - type: Type of subclass of `NSManagedObject` expected to be that of the retrieved object.
  ///     Failure to cast a found object to this type by this function results in an error being
  ///     thrown.
  fileprivate func object<Object>(
    with id: NSManagedObjectID,
    as type: Object.Type
  ) async throws(PersistenceError) -> Object where Object: NSManagedObject {
    try await performWithTypedThrowsCastToPersistenceError { try self.object(with: id, as: type) }
  }

  /// Attempts to convert uncontextualized errors throwable by the given closure into
  /// ``PersistenceError``s, as the errors thrown by CoreData tend to be plain instances of
  /// `NSError` instead of discrete cases, requiring extensive reading and understanding of its
  /// documentation.
  ///
  /// - Parameter closure: Closure which may throw the non-discrete errors of CoreData described in
  ///   the documentation of the function. `NSError`s thrown by this closure will be interpreted as
  ///   failures due to an inconsistent update of an object persisted in this container.
  private func performWithTypedThrowsCastToPersistenceError<Result>(
    _ closure: @escaping @Sendable () throws -> Result
  ) async throws(PersistenceError) -> Result {
    do {
      return try await perform(closure)
    } catch let error as NSError {
      throw .inconsistentUpdate(underlyingError: error)
    } catch let error as PersistenceError {
      throw error
    } catch let error {
      fatalError(error.localizedDescription)
    }
  }

  /// Retrieves the object saved with the given ID.
  ///
  /// Differs from ``object(with:)`` in that no object is returned in case none is identified with
  /// the ID or exists but is of a type which is not the one specified to this function: faults
  /// (placeholder objects for when an object with some ID was not found) are treated as errors
  /// by this function.
  ///
  /// - Parameters:
  ///   - id: ID of the object to be retrieved, as generated by CoreData.
  ///   - type: Type of subclass of `NSManagedObject` expected to be that of the retrieved object.
  ///     Failure to cast a found object to this type by this function results in an error being
  ///     thrown.
  func object<Object>(
    with id: NSManagedObjectID,
    as type: Object.Type
  ) throws(PersistenceError) -> Object where Object: NSManagedObject {
    guard let object = self.object(with: id) as? Object, !object.isFault else {
      throw PersistenceError.objectNotFound(id: id)
    }
    return object
  }
}

/// Failure happened upon reading the value of a property of a persisted object or a saving changes
/// (insertions, updates or deletions) to a persistent container.
enum PersistenceError: Error {
  /// An object required to have been persisted and identified with the provided identifier is not
  /// in the container. This error should not occur, as it denotes a bug in the persistence logic
  /// itself.
  ///
  /// - Parameter id: ID of the object which should have been persisted in the container.
  case objectNotFound(id: any Sendable)

  /// An object of the given type does not contain a property whose name is the specified one, or
  /// the value of such property is `nil` while required to have been set. This error indicates an
  /// incorrect modeling of the object and, therefore, should not occur.
  ///
  /// - Parameters:
  ///   - objectType: Type of the persisted object whose property or its value is missing.
  ///   - key: Name of the property expected to be a member of the object and have a non-`nil` value
  ///     assigned to it.
  case missingValue(objectType: NSManagedObject.Type, key: String)

  /// This error is thrown because CoreData itself threw an error while saving an object, and may be
  /// due to such object not having had its required values set, or set to ones without the required
  /// conformances.
  ///
  /// - Parameter underlyingError: The error thrown by CoreData. For details on its contents, refer
  ///   to the documentation of ``NSManagedObjectContext/save()``.
  case inconsistentUpdate(underlyingError: NSError)
}

/// Returns the value whose key path is the given one in the root. Ideal for ensuring the presence
/// of such value in cases that require it to exist, in which its absence denotes an error from
/// which the program should not or cannot recover.
///
/// - Parameters:
///   - keyPath: Key path of the value being required in the `root`.
///   - key: Provides the name of the member of `root` to which the value is assigned.
///   - root: Instance containing the member providing the value.
fileprivate func require<Root, Value>(
  _ keyPath: KeyPath<Root, Optional<Value>>,
  keyed key: @autoclosure () -> String,
  in root: Root
) throws(PersistenceError) -> Value where Root: NSManagedObject {
  try require(root[keyPath: keyPath], keyed: key(), in: root)
}

/// Returns the value wrapped by the given optional. Ideal for ensuring the presence of such value
/// in cases that require it to exist, in which its absence denotes an error from which the program
/// should not or cannot recover.
///
/// - Parameters:
///   - wrappedValue: Optional whose underlying value is being required.
///   - key: Provides the name of the member of `root` to which the value is assigned.
///   - root: Instance containing the member providing the value.
fileprivate func require<Root, Value>(
  _ wrappedValue: Optional<Value>,
  keyed key: @autoclosure () -> String,
  in root: Root
) throws(PersistenceError) -> Value where Root: NSManagedObject {
  guard let unwrappedValue = wrappedValue else {
    throw .missingValue(objectType: Root.self, key: key())
  }
  return unwrappedValue
}
