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

public extension ModelContextQueue {
  /// Pseudo-type-erased version of a strategy for fetching models. Ultimately,
  /// acts as a wrapper which allows for static access to the implementations of
  /// the strategy protocol.
  struct AnyFetchStrategy<Base, PersistentModelType>: FetchStrategy
  where Base: FetchStrategy, Base.PersistentModelType == PersistentModelType {
    /// The backing, delegate strategy.
    private let base: Base

    public func fetch(
      through backingContext: ModelContext,
      withDescriptor fetchDescriptor: FetchDescriptor<PersistentModelType>
    ) throws -> Base.Result {
      try base.fetch(through: backingContext, withDescriptor: fetchDescriptor)
    }
  }

  /// Fetcher and transformer of the result of having fetched models from a
  /// concurrent context, providing to the user of the API for choosing the
  /// amount of models to fetch and returning a result of an appropriate type
  /// for that amount (e.g., `.one` yields a model; `.all` yields an array of
  /// models).
  protocol FetchStrategy {
    /// Model being fetched.
    associatedtype PersistentModelType: PersistentModel

    /// Instance produced as a consequence of having performed a fetch.
    associatedtype Result

    /// Calls the appropriate functions on the SwiftData context backing the
    /// concurrent one in order to fetch model(s) in an amount equivalent to
    /// that of this strategy (e.g., one, many, …).
    ///
    /// - Parameters:
    ///   - backingContext: Underlying context backing the concurrent one from
    ///     which the fetch is being performed.
    ///   - fetchDescriptor: Descriptor with the predicate and the sorting of
    ///     the models to be fetched.
    /// - Throws: The error thrown by any throwing function of the
    ///   `backingContext` called by the implementation.
    func fetch(
      through backingContext: ModelContext,
      withDescriptor fetchDescriptor: FetchDescriptor<PersistentModelType>
    ) throws -> Result
  }
}

// MARK: - .count

public extension ModelContextQueue.AnyFetchStrategy
where Base == ModelContextQueue.CountFetchStrategy<PersistentModelType> {
  /// Fetches the amount of models matching the predicate.
  static var count: Self { .init(base: .init()) }
}

public extension ModelContextQueue {
  /// Fetch strategy of ``AnyFetchStrategy/count``.
  struct CountFetchStrategy<PersistentModelType>: FetchStrategy
  where PersistentModelType: PersistentModel {
    public func fetch(
      through backingContext: ModelContext,
      withDescriptor fetchDescriptor: FetchDescriptor<PersistentModelType>
    ) throws -> Int { try backingContext.fetchCount(fetchDescriptor) }
  }
}

// MARK: - .one

public extension ModelContextQueue.AnyFetchStrategy
where Base == ModelContextQueue.OneFetchStrategy<PersistentModelType> {
  /// Fetches a single model matching the predicate.
  static var one: Self { .init(base: .init()) }
}

public extension ModelContextQueue {
  /// Fetch strategy of ``AnyFetchStrategy/one``.
  struct OneFetchStrategy<PersistentModeltype>: FetchStrategy
  where PersistentModeltype: PersistentModel {
    public func fetch(
      through backingContext: ModelContext,
      withDescriptor fetchDescriptor: FetchDescriptor<PersistentModeltype>
    ) throws -> PersistentModeltype? {
      try backingContext.fetch(fetchDescriptor, batchSize: 1).first
    }
  }
}

// MARK: - .all

public extension ModelContextQueue.AnyFetchStrategy
where Base == ModelContextQueue.AllFetchStrategy<PersistentModelType> {
  /// Fetches every model matching the predicate.
  static var all: Self { .init(base: .init()) }
}

public extension ModelContextQueue {
  /// Fetch strategy of ``AnyFetchStrategy/all``.
  struct AllFetchStrategy<PersistentModelType>: FetchStrategy
  where PersistentModelType: PersistentModel {
    public func fetch(
      through backingContext: ModelContext,
      withDescriptor fetchDescriptor: FetchDescriptor<PersistentModelType>
    ) throws -> [PersistentModelType] {
      try backingContext.fetch(fetchDescriptor)
    }
  }
}
