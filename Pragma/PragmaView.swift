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

import OnboardingFeature
import PlannerKit
import PlansFeature
import SwiftUI

private let isFirstLaunch =
  Launch.current(from: .standard, updating: true).count == 1

struct PragmaView<PlannerType>: View where PlannerType: PlanRepository {
  var body: some View {
    if isOnboarding {
      OnboardingCarousel(onNext: { isOnboarding = false })
    } else {
      Plans(viewModel: plansViewModel)
    }
  }

  private let plansViewModel: PlansViewModel<PlannerType>

  @State
  private var isOnboarding = isFirstLaunch

  init(plansViewModel: PlansViewModel<PlannerType>) {
    self.plansViewModel = plansViewModel
  }
}
