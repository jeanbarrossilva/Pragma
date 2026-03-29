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

/// A model context queue (MCQ) is a wrapper around a SwiftData model context
/// (SMC), allowing for performing enqueued operations on the SMC
/// asynchronously.
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
/// Massicotte. Because of these unexplained behaviors, an MCQ is the
/// recommended approach for using SwiftData asynchronously in Pragma.
///
/// ## Auto-saving
///
/// Apart from the concurrency aspect, an MCQ differs from an SMC in that it
/// *never* saves changes automatically. This is intentional, given that
/// performing operations immediately and sequentially may be expensive.
///
/// Because an MCQ is a queue, its operations are enqueued: calling any of its
/// CRUD functions will not perform its respective operation right away; rather,
/// a request for it is stored, and all are performed in a single transaction
/// upon the next call to ``flush()``.
///
/// ## Sendability
///
/// An MCQ is backed by an SMC internally. An SMC is not sendable:
///
/// 1. It exposes properties storing models that have been inserted, deleted,
///    and other data modifiable by one of the methods of the SMC; and
/// 2. it is not an actor, with accesses to those properties being
///    non-thread-safe.
///
/// An MCQ *may* be sendable because it is an actor,
/// [with each access being isolated](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/concurrency#Isolation)
/// (including accesses to its backing SMC). Conformance to `Sendable` by an MCQ
/// will only be safe *if* accesses to its ``backingContext`` do not mutate the
/// state of the MCQ.
public actor ModelContextQueue {
  /// SwiftData model context backing each operation and batch of operations.
  public let backingContext: ModelContext

  /// Requests for operations to be performed upon the next call to ``flush()``.
  /// Is `nil` by default, and gets assigned an array with at least one request
  /// once ``enqueue(_:)`` is called.
  private var requests: OrderedSet<AnyRequest>?

  /// Initializes a concurrent context backed by a SwiftData model one.
  ///
  /// - Parameter container: Container into which changes performed in memory by
  ///   the concurrent context will be persisted.
  init(container: ModelContainer) {
    self.backingContext = .init(container)
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
    var requests = self.requests ?? []
    requests.append(.init(request))
    self.requests = requests
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
  func fetch<PersistentModelType>(
    where predicate: Predicate<PersistentModelType>,
    sortingBy sorting: [SortDescriptor<PersistentModelType>]
  ) throws -> [PersistentModelType] where PersistentModelType: PersistentModel {
    var fetchDescriptor = FetchDescriptor(predicate: predicate, sortBy: sorting)
    fetchDescriptor.includePendingChanges = false
    return try AllFetchStrategy()
      .fetch(through: backingContext, withDescriptor: fetchDescriptor)
  }

  /// Obtains models inserted into the container in order of insertion.
  ///
  /// - Parameters:
  ///   - strategy: Determines both the amount of models which match the
  ///     `predicate` that should be returned and the type of return of this
  ///     function. For example: in case the intent is to fetch a single model,
  ///     ``AnyFetchStrategy/one`` would be passed into this parameter, and an
  ///     instance of a model (rather than a single-element collection
  ///     containing it) would be returned.
  ///   - predicate: Condition to be satisfied by the models returned by this
  ///     function.
  /// - Throws: If the `predicate` is malformed.
  func fetch<Strategy>(
    _ strategy: AnyFetchStrategy<Strategy, Strategy.PersistentModelType>,
    where predicate: Predicate<Strategy.PersistentModelType>
  ) throws -> Strategy.Result where Strategy: FetchStrategy {
    var fetchDescriptor = FetchDescriptor(predicate: predicate)
    fetchDescriptor.includePendingChanges = false
    return try strategy.fetch(
      through: backingContext,
      withDescriptor: fetchDescriptor
    )
  }

  /// Performs pending operations in first in, first out (FIFO) order in one
  /// transaction if there are any; in case no operations have been enqueued,
  /// calling this method is a no-op.
  ///
  /// - Throws: In case the backing SwiftData context fails to save. The reasons
  ///   of failure are mostly unknown, as they are not covered by the SwiftData
  ///   documentation.
  func flush() async throws {
    guard let requests, !requests.isEmpty, backingContext.hasChanges else {
      return
    }
    try await backingContext.waitForTransaction {
      for request in requests {
        try request.performOperation(in: backingContext)
      }
    }
    self.requests!.removeAll()
  }
}

extension ModelContext {
  /// Performs a transaction (i.e., batch of operations) asynchronously,
  /// suspending until each pending operation finishes being performed.
  /// Afterwards, changes are saved.
  ///
  /// - Parameter block: Closure by which the operations included in the
  ///   transaction are performed. They are saved after the call to this
  ///   closure by this function.
  fileprivate func waitForTransaction(block: () throws -> Void) async throws {
    try await withCheckedThrowingContinuation { continuation in
      do {
        try transaction { try block() }
        continuation.resume()
      } catch { continuation.resume(throwing: error) }
    }
  }
}
