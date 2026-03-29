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
    private let isBaseEqual: (any Request) -> Bool

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

    func performOperation(in backingContext: ModelContext) throws {
      try base.performOperation(in: backingContext)
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

extension ModelContextQueue {
  /// An intent to perform an operation on the backing context of a concurrent
  /// context. Because operations of a concurrent context are not performed
  /// immediately (but, rather, scheduled), instances conforming to this
  /// protocol are stored upon requests to their respective operations.
  protocol Request: Hashable {
    /// Performs the operation associated to this request (e.g., for an
    /// insertion request, inserts a model) on the context by which the
    /// concurrent one is backed.
    ///
    /// - Parameter backingContext: SwiftData context in which the operation
    ///   will be performed.
    func performOperation(in backingContext: ModelContext) throws
  }
}

// MARK: - Insertion

extension ModelContextQueue.Request {
  /// Request for inserting a model into a context.
  ///
  /// - Parameter model: Model to be inserted.
  static func insertion<PersistentModelType>(
    of model: PersistentModelType
  ) -> ModelContextQueue.InsertionRequest<PersistentModelType>
  where
    Self == ModelContextQueue.InsertionRequest<PersistentModelType>,
    PersistentModelType: PersistentModel
  { .init(model: model) }
}

extension ModelContextQueue {
  /// Request of ``Request/insertion(of:)``.
  struct InsertionRequest<PersistentModelType>: Request
  where PersistentModelType: PersistentModel {
    /// Model to be inserted.
    private let model: PersistentModelType

    /// Initializes a request for insertion.
    ///
    /// - Parameter model: Model to be inserted.
    init(model: PersistentModelType) { self.model = model }

    func performOperation(in backingContext: ModelContext) throws {
      backingContext.insert(model)
    }
  }
}

// MARK: - Deletion (one)

extension ModelContextQueue.Request {
  /// Request for deleting a model from a context.
  ///
  /// - Parameter model: Model to be deleted.
  static func deletion<PersistentModelType>(
    of model: PersistentModelType
  ) -> ModelContextQueue.DeletionOfOneRequest<PersistentModelType>
  where
    Self == ModelContextQueue.DeletionOfOneRequest<PersistentModelType>,
    PersistentModelType: PersistentModel
  { .init(model: model) }
}

extension ModelContextQueue {
  /// Request of ``Request/deletion(of:)``.
  struct DeletionOfOneRequest<PersistentModelType>: Request
  where PersistentModelType: PersistentModel {
    /// Model to be deleted.
    private let model: PersistentModelType

    /// Initializes a request for deletion of one model.
    ///
    /// - Parameter model: Model to be deleted.
    init(model: PersistentModelType) { self.model = model }

    func performOperation(in backingContext: ModelContext) throws {
      backingContext.delete(model)
    }
  }
}

extension ModelContextQueue.DeletionOfOneRequest: Equatable {
  static func == (lhs: Self, rhs: Self) -> Bool { lhs.model == rhs.model }
}

extension ModelContextQueue.DeletionOfOneRequest: Hashable {
  func hash(into hasher: inout Hasher) { model.hash(into: &hasher) }
}

// MARK: - Deletion (many)

extension ModelContextQueue.Request {
  /// Request for deletion of many models.
  ///
  /// - Parameter predicate: Condition satisfied by models to be deleted.
  static func deletion<PersistentModelType>(
    where predicate: Predicate<PersistentModelType>
  ) -> ModelContextQueue.DeletionOfManyRequest<PersistentModelType>
  where
    Self == ModelContextQueue.DeletionOfManyRequest<PersistentModelType>,
    PersistentModelType: PersistentModel
  { .init(predicate: predicate) }
}

extension ModelContextQueue {
  /// Request of ``Request/deletion(where:)``.
  struct DeletionOfManyRequest<PersistentModelType>: Request
  where PersistentModelType: PersistentModel {
    /// Condition satisfied by models to be deleted.
    private let predicate: Predicate<PersistentModelType>

    /// Initializes a request for deletion of many models.
    ///
    /// - Parameter predicate: Condition satisfied by models to be deleted.
    init(predicate: Predicate<PersistentModelType>) {
      self.predicate = predicate
    }

    func performOperation(in backingContext: ModelContext) throws {
      try backingContext.delete(
        model: PersistentModelType.self,
        where: predicate,
        includeSubclasses: false
      )
    }
  }
}

extension ModelContextQueue.DeletionOfManyRequest: Equatable {
  static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.predicate.description == rhs.predicate.description
  }
}

extension ModelContextQueue.DeletionOfManyRequest: Hashable {
  func hash(into hasher: inout Hasher) {
    predicate.description.hash(into: &hasher)
  }
}
