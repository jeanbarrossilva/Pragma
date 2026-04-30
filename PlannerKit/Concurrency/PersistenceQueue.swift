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

/// A persistence queue is a wrapper around a SwiftData container, acting as a
/// queue data structure and allowing for performing enqueued operations on the
/// container asynchronously.
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
/// Massicotte. Because of these unexplained behaviors, a persistence queue is
/// the recommended approach for using SwiftData asynchronously in Pragma.
///
/// ## Auto-saving
///
/// Apart from the concurrency aspect, a persistence queue differs from the bare
/// context of a container in that it *never* saves changes automatically. This
/// is intentional, given that performing operations immediately and
/// sequentially may be expensive.
///
/// Because it is a queue, its operations are enqueued: requests for them are
/// stored, and all are performed in FIFO order upon the next call to
/// ``flush()``.
///
/// ## Sendability
///
/// A persistence queue is backed by a context. A container, by itself, is not
/// sendable:
///
/// 1. Its main context is public, and exposes properties storing models that
///    have been inserted, deleted, and other data modifiable by one of the
///    methods of the context; and
/// 2. it is not an actor, with accesses to those properties being
///    non-thread-safe.
///
/// A persistence queue, however, is sendable because it is an actor,
/// [with each access being isolated](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/concurrency#Isolation)
/// (including accesses to its backing container).
public actor PersistenceQueue: Sendable {
  /// Context on which updates to the ``backingContainer`` will be performed
  /// until the next flush.
  ///
  /// - SeeAlso: ``flush()``
  private(set) var currentContext: ModelContext

  /// Types of the models which can be inserted.
  let modelTypes: AnySequence<any PersistentModel.Type>

  /// Container backing each operation or transaction.
  private let backingContainer: ModelContainer

  /// Requests for operations to be performed upon the next call to ``flush()``.
  /// This is `nil` by default, and gets assigned an array with at least one
  /// request once ``enqueue(_:)`` is called.
  private var requests: OrderedSet<AnyRequest>?

  /// Initializes a ``PersistenceQueue`` backed by a SwiftData container.
  ///
  /// - Parameters:
  ///   - backingContainer: SwiftData container backing the queue.
  ///   - modelTypes: Types of the models which can be inserted.
  init(
    backingContainer: ModelContainer,
    modelTypes: some Sequence<any PersistentModel.Type>
  ) {
    self.backingContainer = backingContainer
    self.currentContext = Self.makeContext(for: backingContainer)
    self.modelTypes = .init(modelTypes)
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
      .fetch(through: currentContext, withDescriptor: fetchDescriptor)
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
      through: currentContext,
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
      try currentContext.save()
    } else {
      try await currentContext.transactAndWait {
        try self.assumeIsolated { persistenceQueue in
          let currentContext = persistenceQueue.currentContext
          for request in requests {
            try request.performOperation(in: persistenceQueue)

            // According to ModelContext's transaction(block:)'s documentation,
            // the changes made within the transaction are supposed to be saved
            // automatically; however, that does not happen as of the SwiftData
            // in Xcode 26.3's bundled Swift toolchain.
            //
            // (Or maybe it does, but in another queue, after the closure or the
            // method itself returns. Either way, there is no documented
            // approach for knowing when that potential save occurs.)
            //
            // https://developer.apple.com/documentation/swiftdata/modelcontext/transaction(block:)
            guard currentContext.hasChanges else { return }
            try currentContext.save()
          }
        }
      }
    }
    currentContext = Self.makeContext(for: backingContainer)
    self.requests!.removeAll()
  }

  /// Produces a context into which models may be inserted and from which
  /// inserted ones may be deleted. Changes in the returned context are not
  /// saved automatically; rather, they should be saved when this queue gets
  /// flushed.
  ///
  /// - Parameter container: Container into which changes by the context may be
  ///   saved.
  /// - Returns: A newly-created, non-auto-saving SwiftData model context.
  private static func makeContext(for container: ModelContainer) -> ModelContext
  {
    let context = ModelContext(container)
    context.autosaveEnabled = false
    return context
  }

  /// Makes a fetch descriptor with configuration common to all overloads of
  /// ``fetch(_:)``.
  ///
  /// - Parameters:
  ///   - predicate: Condition to be satisfied by the models to be fetched.
  ///   - sorting: Descriptors with the properties of each model by which they
  ///     will be ordered. In scenarios in which the order is not important or
  ///     models should be unordered, instead of initializing an empty sequence
  ///     and handing it to this function, `nil` should be passed in.
  private static func makeFetchDescriptor<Model>(
    where predicate: Predicate<Model>,
    sortingBy sorting: (some Sequence<SortDescriptor<Model>>)?
  ) -> FetchDescriptor<Model> where Model: PersistentModel {
    var fetchDescriptor = FetchDescriptor(predicate: predicate)
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
