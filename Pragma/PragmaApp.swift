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

import PlannerKit
import PlansFeature
import SwiftData
import SwiftUI

@main
struct PragmaApp: App {
  var body: some Scene {
    WindowGroup {
      Group {
        if let viewModel, let context = contextSnapshot?.copy() {
          // The `View.modelContext(_:)` modifier by SwiftData should be applied to this view;
          // however, such function is not identified by the compiler as one of the members of a
          // PragmaView. I suppose it has something to do with its generic type, but have not gone
          // into it yet.
          PragmaView(plansViewModel: viewModel)
        }
      }
      .task {
        do {
          let viewModel = try await PlansViewModel(planner: .persistent)
          self.viewModel = viewModel
          self.contextSnapshot =
            await viewModel.planner.context.run { context in Snapshot(of: context.backingContext) }
        } catch {
          fatalError(error.localizedDescription)
        }
      }
    }
  }

  @State
  private var viewModel: PlansViewModel<PersistentPlanner>?

  @State
  private var contextSnapshot: Snapshot<ModelContext>?
}
