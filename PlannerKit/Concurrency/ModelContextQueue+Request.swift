// ===-----------------------------------------------------------------------===
// Copyright © 2026 Jean Silva
//
// This file is part of the Pragma open-source project.
//
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later
// version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
// details.
//
// You should have received a copy of the GNU General Public License along with
// this program. If not, see https://www.gnu.org/licenses.
// ===-----------------------------------------------------------------------===

import SwiftData

extension ModelContextQueue {
  /// Request whose type information (e.g., regarding the operation it performs)
  /// has been erased.
  struct AnyRequest: Request {
    /// The original request.
    private let base: any Request

    /// Determines whether the base request is equal to another request. This
    /// closure will return `false` in case they are of different types.
    private let isBaseEqual: @Sendable (any Request) -> Bool

    /// Initializes a request without type information.
    ///
    /// - Parameter base: The original request.
    init<Base>(_ base: Base) where Base: Request {
      if let base = base as? AnyRequest {
        self.base = base.base
        self.isBaseEqual = base.isBaseEqual
      } else {
        self.base = base
        self.isBaseEqual = { other in
          guard let other = other as? Base else { return false }
          return base == other
        }
      }
    }

    func performOperation(in contextQueue: isolated ModelContextQueue) throws {
      try base.performOperation(in: contextQueue)
    }
  }
}

extension ModelContextQueue.AnyRequest: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.isBaseEqual(rhs.base)
  }
}

extension ModelContextQueue.AnyRequest: Hashable {
  func hash(into hasher: inout Hasher) { base.hash(into: &hasher) }
}

public extension ModelContextQueue {
  /// An intent to perform an operation on the backing context of a concurrent
  /// context. Because operations of a concurrent context are not performed
  /// immediately (but, rather, scheduled), instances conforming to this
  /// protocol are stored upon requests to their respective operations.
  protocol Request: Hashable, Sendable {
    /// Performs the operation associated to this request (e.g., for an
    /// insertion request, inserts a model) on the given context queue.
    ///
    /// - Parameter contextQueue: Context queue on which the operation of this
    ///   request will be performed.
    func performOperation(in contextQueue: isolated ModelContextQueue) throws
  }
}

// MARK: - Insertion

public extension ModelContextQueue.Request {
  /// Request for inserting a model.
  ///
  /// - Parameter model: Model to be inserted.
  static func insertion<Model>(
    of model: Model
  ) -> ModelContextQueue.InsertionRequest<Model>
  where
    Self == ModelContextQueue.InsertionRequest<Model>, Model: PersistentModel
  { .init(model: model) }
}

public extension ModelContextQueue {
  /// Request of ``Request/insertion(of:)``.
  struct InsertionRequest<Model>: Request
  where Model: NSCopying & PersistentModel {
    /// Snapshot of the model to be inserted.
    private let modelSnapshot: Snapshot<Model>

    /// Initializes a request for insertion.
    ///
    /// - Parameter model: Model to be inserted.
    init(model: Model) { modelSnapshot = .init(of: model) }

    public func performOperation(
      in contextQueue: isolated ModelContextQueue
    ) throws {
      let model = modelSnapshot.copy()
      contextQueue.backingContext.insert(model)
    }
  }
}

// MARK: - Deletion (one)

public extension ModelContextQueue.Request {
  /// Request for deleting a model.
  ///
  /// Attempts to delete nonexistent models, i.e., flushing the queue with such
  /// a request while the specified ID is not that of a model of the given type,
  /// are ignored.
  ///
  /// - Parameters:
  ///   - modelType: Type of the model to be deleted.
  ///   - modelID: ID of the model to be deleted.
  static func deletion<Model>(
    of modelType: Model.Type,
    identifiedAs modelID: PersistentIdentifier
  ) -> ModelContextQueue.DeletionOfOneRequest<Model>
  where
    Self == ModelContextQueue.DeletionOfOneRequest<Model>,
    Model: PersistentModel
  { .init(modelID: modelID) }
}

public extension ModelContextQueue {
  /// Request of ``Request/deletion(of:)``.
  struct DeletionOfOneRequest<Model>: Request where Model: PersistentModel {
    /// ID of the model to be deleted.
    private let modelID: PersistentIdentifier

    /// Initializes a request for deletion of one model.
    ///
    /// - Parameter modelID: ID of the model to be deleted.
    init(modelID: PersistentIdentifier) { self.modelID = modelID }

    public func performOperation(
      in contextQueue: isolated ModelContextQueue
    ) throws {
      let backingContext = contextQueue.backingContext
      guard let model: Model = backingContext.registeredModel(for: modelID)
      else { return }
      backingContext.delete(model)
    }
  }
}

extension ModelContextQueue.DeletionOfOneRequest: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.modelID == rhs.modelID
  }
}

extension ModelContextQueue.DeletionOfOneRequest: Hashable {
  public func hash(into hasher: inout Hasher) { modelID.hash(into: &hasher) }
}

// MARK: - Deletion (many)

public extension ModelContextQueue.Request {
  /// Request for deletion of many models of a given type.
  ///
  /// - Parameter modelType: Type of the models to be deleted.
  static func deletion<Model>(
    ofType modelType: Model.Type
  ) -> ModelContextQueue.DeletionOfManyRequest<Model>
  where
    Self == ModelContextQueue.DeletionOfManyRequest<Model>,
    Model: PersistentModel
  { .deletion(where: Predicate<Model>.true) }

  /// Request for deletion of many models.
  ///
  /// - Parameter predicate: Condition satisfied by models to be deleted.
  static func deletion<Model>(
    where predicate: Predicate<Model>
  ) -> ModelContextQueue.DeletionOfManyRequest<Model>
  where
    Self == ModelContextQueue.DeletionOfManyRequest<Model>,
    Model: PersistentModel
  { .init(predicate: predicate) }
}

public extension ModelContextQueue {
  /// Request of ``Request/deletion(where:)``.
  struct DeletionOfManyRequest<Model>: Request where Model: PersistentModel {
    /// Condition satisfied by models to be deleted.
    private let predicate: Predicate<Model>

    /// Initializes a request for deletion of many models.
    ///
    /// - Parameter predicate: Condition satisfied by models to be deleted.
    init(predicate: Predicate<Model>) { self.predicate = predicate }

    public func performOperation(
      in contextQueue: isolated ModelContextQueue
    ) throws {
      try contextQueue.backingContext.delete(
        model: Model.self,
        where: predicate,
        includeSubclasses: false
      )
    }
  }
}

extension ModelContextQueue.DeletionOfManyRequest: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.predicate.description == rhs.predicate.description
  }
}

extension ModelContextQueue.DeletionOfManyRequest: Hashable {
  public func hash(into hasher: inout Hasher) {
    predicate.description.hash(into: &hasher)
  }
}

// MARK: - Deletion (all)

public extension ModelContextQueue.Request
where Self == ModelContextQueue.DeletionOfAllRequest {
  /// Request for deletion of every model.
  ///
  /// - Warning: Once this request is enqueued and flushed, its operation cannot
  ///   be undone.
  static var deletionOfAll: Self { .init() }
}

public extension ModelContextQueue {
  /// Request of ``Request/deletionOfAll``.
  struct DeletionOfAllRequest: Request {
    public func performOperation(
      in contextQueue: isolated ModelContextQueue
    ) throws {
      for modelType in contextQueue.modelTypes {
        try contextQueue.backingContext.delete(model: modelType)
      }
    }
  }
}
