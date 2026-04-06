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

internal import Collections

/// A model context queue is a wrapper around a SwiftData model context,
/// allowing for performing enqueued operations on the context asynchronously.
///
/// ## Disadvantages of concurrency built into SwiftData
///
/// SwiftData exposes an API for making the
/// [stack](https://developer.apple.com/documentation/coredata/setting-up-a-core-data-stack)
/// by which the container is referenced asynchronous — the `ModelActor` macro.
/// However, the isolation of the resulting actor is that of the main actor,
/// i.e., requests for operations are performed on the UI thread (the operations
/// themselves *are not*), and its underlying machinery is largely undocumented
/// by Apple.
///
/// For more details on the quirks of `ModelActor`, see
/// ["ModelActor Is Just Weird"](https://www.massicotte.org/model-actor) by Matt
/// Massicotte. Because of these unexplained behaviors, a context queue is the
/// recommended approach for using SwiftData asynchronously in Pragma.
///
/// ## Auto-saving
///
/// Apart from the concurrency aspect, a context queue differs from a bare
/// context in that it *never* saves changes automatically. This is intentional,
/// given that performing operations immediately and sequentially may be
/// expensive.
///
/// Because it is a queue, its operations are enqueued: requests for them are
/// stored, and all are performed in first in, first out order (FIFO) upon the
/// next call to ``flush()``.
///
/// ## Sendability
///
/// A context queue is backed by a context. A context, by itself, is not
/// sendable:
///
/// 1. It exposes properties storing models that have been inserted, deleted,
///    and other data modifiable by one of the methods of the context; and
/// 2. it is not an actor, with accesses to those properties being
///    non-thread-safe.
///
/// A queue, however, is sendable because it is an actor,
/// [with each access being isolated](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/concurrency#Isolation)
/// (including accesses to its backing context).
public actor ModelContextQueue: Sendable {
  /// Context backing each operation or transaction.
  let backingContext: ModelContext

  /// Types of the models which can be inserted.
  let modelTypes: AnySequence<any PersistentModel.Type>

  /// Requests for operations to be performed upon the next call to ``flush()``.
  /// This is `nil` by default, and gets assigned an array with at least one
  /// request once ``enqueue(_:)`` is called.
  private var requests: OrderedSet<AnyRequest>?

  /// Initializes a ``ModelContextQueue`` backed by a SwiftData model context.
  ///
  /// - Parameters:
  ///   - backingContext: SwiftData model context backing each operation or
  ///     transaction.
  ///   - modelTypes: Types of the models which can be inserted.
  init(
    backingContext: ModelContext,
    modelTypes: some Sequence<any PersistentModel.Type>
  ) {
    self.backingContext = backingContext
    self.modelTypes = .init(modelTypes)
    backingContext.autosaveEnabled = false
  }

  /// Prepares the operation of a given request for execution when the changes
  /// made to this context are flushed (upon the next call to ``flush()``). Each
  /// operation will be performed sequentially, following the order in which
  /// they have been scheduled.
  ///
  /// - Parameter request: Request of the operation to be performed upon the
  ///   next flush.
  func enqueue(_ request: some Request) {
    let typeErasedRequest = AnyRequest(request)
    if let _ = requests {
      requests!.append(typeErasedRequest)
    } else {
      requests = [typeErasedRequest]
    }
  }

  /// Obtains models inserted into the container, with these models ordered
  /// according to the specified properties of theirs.
  ///
  /// - Parameters:
  ///   - predicate: Condition to be satisfied by the models returned by this
  ///     function.
  ///   - sorting: Descriptors with the properties of each model by which they
  ///     will be ordered.
  /// - Throws: If the `predicate` is malformed.
  func fetch<Model>(
    where predicate: Predicate<Model>,
    sortingBy sorting: some Sequence<SortDescriptor<Model>>
  ) throws -> [Model] where Model: PersistentModel {
    let fetchDescriptor = Self.makeFetchDescriptor(
      where: predicate,
      sortingBy: sorting
    )
    return try AllFetchStrategy()
      .fetch(through: backingContext, withDescriptor: fetchDescriptor)
  }

  /// Obtains models of a given type inserted into the container in order of
  /// insertion.
  ///
  /// - Parameters:
  ///   - strategy: Determines both the amount of models whose type is the
  ///     specified one should be returned and the type of return of this
  ///     function. For example: in case the intent is to fetch a single model,
  ///     ``FetchStrategy/one`` would be passed into this parameter, and an
  ///     instance of a model (rather than a single-element collection
  ///     containing it) would be returned.
  func fetch<Strategy>(_ strategy: Strategy) throws -> Strategy.Result
  where Strategy: FetchStrategy {
    try fetch(strategy, where: Predicate<Strategy.Model>.true)
  }

  /// Obtains models inserted into the container in order of insertion.
  ///
  /// - Parameters:
  ///   - strategy: Determines both the amount of models which match the
  ///     `predicate` that should be returned and the type of return of this
  ///     function. For example: in case the intent is to fetch a single model,
  ///     ``FetchStrategy/one`` would be passed into this parameter, and an
  ///     instance of a model (rather than a single-element collection
  ///     containing it) would be returned.
  ///   - predicate: Condition to be satisfied by the models returned by this
  ///     function.
  /// - Throws: If the `predicate` is malformed.
  func fetch<Strategy>(
    _ strategy: Strategy,
    where predicate: Predicate<Strategy.Model>
  ) throws -> Strategy.Result where Strategy: FetchStrategy {
    let fetchDescriptor = Self.makeFetchDescriptor(
      where: predicate,
      sortingBy: nil as AnySequence<SortDescriptor<Strategy.Model>>?
    )
    return try strategy.fetch(
      through: backingContext,
      withDescriptor: fetchDescriptor
    )
  }

  /// Performs pending operations in FIFO order in one transaction if there are
  /// any; in case no operations have been enqueued, calling this method is a
  /// no-op.
  ///
  /// Similar to `save()` in a context.
  ///
  /// - Throws: In case the backing context fails to save. The reasons of
  ///   failure are mostly unknown, as they are not covered by the SwiftData
  ///   documentation.
  func flush() async throws {
    guard let requests, !requests.isEmpty else { return }
    if requests.count == 1, let request = requests.first {
      try request.performOperation(in: self)
      try backingContext.save()
    } else {
      try await backingContext.transactAndWait {
        try self.assumeIsolated { context in
          for request in requests { try request.performOperation(in: context) }
        }
      }
    }
    self.requests!.removeAll()
  }

  /// Makes a fetch descriptor with configuration common to all overloads of
  /// ``fetch(_:)``. Because this queue only saves pending operations in the
  /// backing context upon a flush, the changes resulted from them are
  /// disregarded when fetching before flushing.
  ///
  /// - Parameters:
  ///   - predicate: Condition to be satisfied by the models to be fetched.
  ///   - sorting: Descriptors with the properties of each model by which they
  ///     will be ordered. In scenarios in which the order is unimportant or
  ///     models should be unordered, rather than an empty array (that requires
  ///     allocation), `nil` should be passed in.
  private static func makeFetchDescriptor<Model>(
    where predicate: Predicate<Model>,
    sortingBy sorting: (some Sequence<SortDescriptor<Model>>)?
  ) -> FetchDescriptor<Model> where Model: PersistentModel {
    var fetchDescriptor = FetchDescriptor(predicate: predicate)
    fetchDescriptor.includePendingChanges = true
    if let sorting { fetchDescriptor.sortBy = .init(sorting) }
    return fetchDescriptor
  }
}

extension ModelContext {
  /// Performs a transaction (i.e., batch of operations) asynchronously,
  /// suspending until each pending operation finishes being performed.
  /// Afterward, changes are saved.
  ///
  /// - Parameter block: Closure by which the operations included in the
  ///   transaction are performed. They are saved after a non-trowing call to
  ///   this closure by this function.
  fileprivate func transactAndWait(
    block: @escaping @Sendable () throws -> Void
  ) async throws {
    try await withCheckedThrowingContinuation { continuation in
      do {
        try transaction {
          try block()
          continuation.resume()
        }
      } catch { continuation.resume(throwing: error) }
    }
  }
}
