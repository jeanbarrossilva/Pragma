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

import SwiftData
internal import AsyncQueue

/// Different from a bare context provided by SwiftData, a concurrent context is tailored to perform
/// changes to the container in isolation, abstracting some of the complexity of dealing with
/// unsaved changes away and mapping thrown errors to typed SwiftData ones.
///
/// ## On the conformance to Sendable
///
/// A concurrent context is backed by a SwiftData context internally. SwiftData contexts are not
/// sendable, given that they contain properties storing models that have been inserted,
/// deleted, and other data modifiable by one of these contexts' methods. On top of that, these
/// contexts are not actors: access to their properties is not thread-safe.
///
/// A concurrent context *may* be sendable because it is an actor,
/// [with each access being isolated](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/concurrency#Isolation)
/// (including those to its backing SwiftData context). However, a concurrent context will be
/// sendable *only if* accesses to its ``backingContext`` do not mutate the state of the concurrent
/// context.
public actor ConcurrentContext: @unchecked Sendable {
  /// SwiftData context backing each operation and batch of operations.
  public let backingContext: ModelContext

  /// Whether the pending changes (if any) to the ``backingContext`` should be saved. This should be
  /// checked by operations which may not have had any effect (i.e., non-insertion ones); for those
  /// that are guaranteed to mutate the ``backingContext``, ``isInTransaction`` should be checked
  /// instead.
  private var shouldSave: Bool { !isInTransaction && backingContext.hasChanges }

  /// Queue to which transactions are appended within underlying SwiftData transactions. There being
  /// ongoing tasks on this queue denotes that ``isInTransaction`` is `true`; otherwise, no
  /// transactions are taking place, and it is `false`.
  private let queue = ActorQueue<ConcurrentContext>()

  /// Whether a transaction is being performed by this context. This being `true` indicates to
  /// insertions and deletions that they should not save immediately; rather, they will be saved by
  /// the underlying transaction of the ``backingContext``. Batched operations are executed by a
  /// task on the ``queue`` of this concurrent context.
  ///
  /// - SeeAlso:
  ///   - ``transaction(_:)``
  ///   - ``save()``
  private var isInTransaction = false

  /// Initializes a concurrent context backed by a SwiftData one.
  ///
  /// - Parameter container: Container into which changes performed in memory by the concurrent
  ///   context will be persisted.
  init(container: ModelContainer) throws(SwiftDataError) {
    self.backingContext = .init(container)
    self.queue.adoptExecutionContext(of: self)
  }

  /// Performs a series of operations on an isolated instance of this context, guaranteeing that
  /// they either finish successfully as an entire transaction; or fail completely in case some of
  /// them fails, leaving the context as it was prior to the call to this method.
  ///
  /// - Parameter action: Operations to be performed as one transaction on the isolated context.
  /// - Throws: The error thrown by one of the operations in case some failed; or if beginning or
  ///   ending the transaction failed.
  func transaction(
    _ action: @escaping @Sendable (isolated ConcurrentContext) async throws -> Void
  ) throws {
    try backingContext.transaction {
      Task(on: queue) { context in
        context.isInTransaction = true
        defer { context.isInTransaction = false }
        try await action(context)
      }
    }
  }

  /// Persists a model into the container.
  ///
  /// - Parameter model: Model to be inserted.
  /// - Throws: In case the backing SwiftData context fails to save. The reasons of failure are
  ///   mostly unknown, as they are not covered by the SwiftData documentation.
  func insert(_ model: some PersistentModel) throws {
    backingContext.insert(model)
    guard !isInTransaction else { return }
    try backingContext.save()
  }

  /// Obtains models inserted into the container by previous calls to ``insert(_:)``, with these
  /// models ordered according to the specified properties of theirs.
  ///
  /// - Parameters:
  ///   - predicate: Condition to be satisfied by the models returned by this function.
  ///   - sorting: Key paths to the properties of each model by which they will be ordered.
  /// - Throws: If the `predicate` is malformed.
  func fetch<Model, Sorter>(
    where predicate: Predicate<Model>,
    sortingBy sorting: [any KeyPath<Model, Sorter> & Sendable]
  ) throws -> [Model] where Model: PersistentModel, Sorter: Comparable {
    var fetchDescriptor = FetchDescriptor(
      predicate: predicate,
      sortBy: sorting.map({ keyPath in .init(keyPath) })
    )
    fetchDescriptor.includePendingChanges = false
    return try AllFetchStrategy().fetch(in: backingContext, with: fetchDescriptor)
  }

  /// Obtains models inserted into the container by previous calls to ``insert(_:)`` in order of
  /// insertion.
  ///
  /// - Parameters:
  ///   - predicate: Condition to be satisfied by the models returned by this function.
  /// - Throws: If the `predicate` is malformed.
  func fetch<Model>(
    where predicate: Predicate<Model>
  ) throws -> [Model]
  where Model: PersistentModel {
    try fetch(.all, where: predicate)
  }

  /// Obtains models inserted into the container by previous calls to ``insert(_:)`` in order of
  /// insertion.
  ///
  /// - Parameters:
  ///   - strategy: Determines both the amount of models which match the `predicate` that should be
  ///     returned and the type of return of this function. For example: in case the intent is to
  ///     fetch a single model, ``AnyFetchStrategy/one`` would be passed into this parameter, and
  ///     an instance of a model (rather than a single-element collection containing it) would be
  ///     returned.
  ///   - predicate: Condition to be satisfied by the models returned by this function.
  /// - Throws: If the `predicate` is malformed.
  func fetch<Strategy>(
    _ strategy: AnyFetchStrategy<Strategy, Strategy.Model>,
    where predicate: Predicate<Strategy.Model>
  ) throws -> Strategy.Result where Strategy: FetchStrategy {
    var fetchDescriptor = FetchDescriptor(predicate: predicate)
    fetchDescriptor.includePendingChanges = false
    return try strategy.fetch(in: backingContext, with: fetchDescriptor)
  }

  /// Undoes the insertion of a given model into the container.
  ///
  /// - Parameter model: Model to be deleted.
  func delete(_ model: some PersistentModel) throws {
    backingContext.delete(model)
    try save()
  }

  /// Undoes the insertion of models of a given type into the container.
  ///
  /// - Parameter modelType: Type of models to be deleted.
  func deleteAll(ofType modelType: any PersistentModel.Type) throws {
    try backingContext.delete(model: modelType)
    try save()
  }

  /// Undoes the insertion of models into the container which match a given predicate.
  ///
  /// - Parameter predicate: Condition to be satisfied by the models to be deleted.
  /// - Throws: If the backing SwiftData context fails to delete the models or the deletion fails to
  ///   be saved.
  func delete<Model>(where predicate: Predicate<Model>) throws where Model: PersistentModel {
    try backingContext.delete(model: Model.self, where: predicate, includeSubclasses: false)
    try save()
  }

  /// Performs pending operations if there are any; otherwise, calling this method is a no-op.
  ///
  /// > Note: Standalone insertions and deletions are saved in-place; and, when batched, after the
  ///   underlying transaction finishes. Calling this method for saving either of those operations
  ///   is not necessary.
  ///
  /// - SeeAlso:
  ///   - ``insert(_:)``
  ///   - ``delete(_:)``
  ///   - ``transaction(_:)``
  /// - Throws: In case the backing SwiftData context fails to save. The reasons of failure are
  ///   mostly unknown, as they are not covered by the SwiftData documentation.
  func save() throws {
    guard shouldSave else { return }
    try backingContext.save()
  }
}
