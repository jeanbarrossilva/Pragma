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

@testable import PlannerKit
import SwiftData

/// Performs an operation with an independent instance of a persistence queue.
/// This function is aimed at testing, and each operation requested to the queue
/// is performed in memory (instead of persisted). Every insertion made in the
/// given closure is undone by the time this function returns.
///
/// - Parameter body: Closure by which operations regarding a test case are
///   performed on a newly initialized queue. Changes performed on it by this
///   closure are undone afterwards.
func withPersistenceQueue(
  _ body: @Sendable (isolated PersistenceQueue) async throws -> Void
) async throws {
  let backingContainer = try PersistentPlanRepository.makeContainer(
    inMemory: true
  )
  let persistenceQueue = PersistenceQueue(
    backingContainer: backingContainer,
    modelTypes: PersistentPlanRepository.modelTypes
  )
  try await persistenceQueue.run { persistenceQueue in
    try await body(persistenceQueue)
    persistenceQueue.enqueue(.deletionOfAll)
    try await persistenceQueue.flush()
  }
}
