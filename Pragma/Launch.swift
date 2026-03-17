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

/// An execution of the Pragma application.
nonisolated struct Launch {
  /// Amount of times the application has been launched. Is always greater than
  /// 0, with 1 denoting that this is the first time that Pragma has been
  /// launched after being installed or having its data deleted.
  var count: Int

  /// Key by which information about a launch is identified in a `UserDefaults`
  /// object.
  enum Key: String, CaseIterable {
    /// Key for the amount of times the application has been launched stored.
    case count = "LaunchCount"
  }

  private init(count: Int) { self.count = count }

  /// Retrieves information about the current execution of the application from
  /// objects stored in a `UserDefaults` object.
  ///
  /// > Warning: This method should be called with `willUpdate` set to `true`
  ///   only once throughout the lifetime of the application. Doing so multiple
  ///   times will compromise data regarding the current and subsequent
  ///   launches.
  ///
  /// - Parameters:
  ///   - userDefaults: User defaults into which information about the current
  ///     launch are or will be stored.
  ///   - willUpdate: Whether information about the launch should be updated
  ///     upon a call to this function. This will, e.g., increment the property
  ///     containing the amout of times the application has been launched.
  static func current(
    from userDefaults: UserDefaults,
    updating willUpdate: Bool
  ) -> Self {
    let count = userDefaults.integer(forKey: Key.count.rawValue) + 1
    if willUpdate { userDefaults.set(count, forKey: Key.count.rawValue) }
    return .init(count: count)
  }
}
