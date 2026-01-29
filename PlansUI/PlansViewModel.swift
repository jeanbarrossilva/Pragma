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

import Combine
import CorePlanner

@MainActor
public struct PlansViewModel<PlannerType> where PlannerType: Planner {
  var plans: [AnyPlanDescriptor]

  private var planner: PlannerType

  public init(planner: PlannerType) async throws(PlannerError<PlannerType.ImplementationError>) {
    self.planner = planner
    self.plans = try await unsafe callWithTypedThrowsCast(
      to: PlannerError<PlannerType.ImplementationError>.self
    ) {
      try await planner.run {
        planner throws(PlannerError<PlannerType.ImplementationError>) in
        do {
          return try await planner.plans.asyncMap { plan in try await .init(of: plan) }
        } catch let error as PlannerError<PlannerType.ImplementationError> {
          throw error
        } catch {
          fatalError(error.localizedDescription)
        }
      }
    }
  }

  func add(toDo: AnyToDoDescriptor, to goalID: AnyHashable) {}

  func transfer(toDos toDoIDs: [AnyHashable], withStatus status: Status, to goalID: AnyHashable) {}
}
