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

public extension PersistenceQueue {
  /// Fetcher and transformer of the result of having fetched models from a
  /// persistence queue, providing to the user of the API for choosing the
  /// amount of models to fetch and returning a result of an appropriate type
  /// for that amount (e.g., `.one` yields a model; `.all` yields an array of
  /// models).
  protocol FetchStrategy {
    /// Model being fetched.
    associatedtype Model: PersistentModel

    /// Instance produced as a consequence of having performed a fetch.
    associatedtype Result

    /// Calls the appropriate functions on the SwiftData model context backing
    /// the persistence queue in order to fetch model(s) in an amount equivalent
    /// to that of this strategy (e.g., one, many, …).
    ///
    /// - Parameters:
    ///   - context: Context backing the persistence queue from which the fetch
    ///     is being performed.
    ///   - fetchDescriptor: Descriptor with the predicate and the sorting of
    ///     the models to be fetched.
    /// - Throws: The error thrown by any throwing function of the `context`
    ///   called by the implementation.
    func fetch(
      through context: ModelContext,
      withDescriptor fetchDescriptor: FetchDescriptor<Model>
    ) throws -> Result
  }
}

// MARK: - Count

public extension PersistenceQueue.FetchStrategy {
  /// Fetches the amount of models matching the predicate.
  ///
  /// - Parameter modelType: Type of the models whose count may be fetched.
  static func count<Model>(_ modelType: Model.Type) -> Self
  where
    Self == PersistenceQueue.CountFetchStrategy<Model>, Model: PersistentModel
  { .init() }
}

public extension PersistenceQueue {
  /// Fetch strategy of ``AnyFetchStrategy/count``.
  struct CountFetchStrategy<Model>: FetchStrategy where Model: PersistentModel {
    public func fetch(
      through backingContext: ModelContext,
      withDescriptor fetchDescriptor: FetchDescriptor<Model>
    ) throws -> Int { try backingContext.fetchCount(fetchDescriptor) }
  }
}

// MARK: - One

public extension PersistenceQueue.FetchStrategy {
  /// Fetches a single model matching the predicate.
  ///
  /// - Parameter modelType: Type of the model to be fetched.
  static func one<Model>(_ modelType: Model.Type) -> Self
  where Self == PersistenceQueue.OneFetchStrategy<Model>, Model: PersistentModel
  { .init() }
}

public extension PersistenceQueue {
  /// Fetch strategy of ``AnyFetchStrategy/one``.
  struct OneFetchStrategy<Model>: FetchStrategy where Model: PersistentModel {
    public func fetch(
      through backingContext: ModelContext,
      withDescriptor fetchDescriptor: FetchDescriptor<Model>
    ) throws -> Model? { try backingContext.fetch(fetchDescriptor).first }
  }
}

// MARK: - All

public extension PersistenceQueue.FetchStrategy {
  /// Fetches every model matching the predicate.
  ///
  /// - Parameter modelType: Type of the models to be fetched.
  static func all<Model>(_ modelType: Model.Type) -> Self
  where Self == PersistenceQueue.AllFetchStrategy<Model>, Model: PersistentModel
  { .init() }
}

public extension PersistenceQueue {
  /// Fetch strategy of ``AnyFetchStrategy/all``.
  struct AllFetchStrategy<Model>: FetchStrategy where Model: PersistentModel {
    public func fetch(
      through backingContext: ModelContext,
      withDescriptor fetchDescriptor: FetchDescriptor<Model>
    ) throws -> [Model] { try backingContext.fetch(fetchDescriptor) }
  }
}
