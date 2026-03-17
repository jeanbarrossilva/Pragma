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

import Foundation
@testable import Pragma
import Testing

struct LaunchTests: ~Copyable {
  private let userDefaults = UserDefaults()

  init() {
    for key in Launch.Key.allCases {
      userDefaults.removeObject(forKey: key.rawValue)
    }
  }

  @Test(arguments: [false, true])
  func launchCountIsOneByDefault(updating willUpdate: Bool) {
    let launch = Launch.current(from: userDefaults, updating: willUpdate)
    #expect(launch.count == 1)
  }

  @Test
  func launchCountIsNotIncrementedInUserDefaultsWhenNotUpdating() {
    let _ = Launch.current(from: userDefaults, updating: false)
    #expect(userDefaults.integer(forKey: Launch.Key.count.rawValue) == 0)
  }

  @Test
  func launchCountIsIncrementedInUserDefaultsWhenUpdating() {
    let _ = Launch.current(from: userDefaults, updating: true)
    #expect(userDefaults.integer(forKey: Launch.Key.count.rawValue) == 1)
  }
}
