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

import SwiftUI

#Preview {
  Callout {
    Button {
    } label: {
      Image(systemName: "plus")
    }
  } title: {
    Text("Here goes some clever title.")
  } description: {
    Text("And, then, a description. Should not be very long, though.")
  }.padding()
}

/// Container with a message about an action which either can or should be done in order for some
/// feature of the application to be taken advantage of, alongside a button for performing the
/// action when triggered. This is for hinting toward an aspect of such feature only, and should not
/// be employed for displaying critical information such as errors.
struct Callout<Title, Description, ActionButton>: View
where Title: View, Description: View, ActionButton: View {
  var body: some View {
    GroupBox {
      HStack(spacing: 24) {
        Image(systemName: "lightbulb.max.fill").imageScale(.large)
        VStack(alignment: .leading, spacing: 4) {
          title().font(.system(.headline, weight: .medium))
          description()
        }
        Spacer()
        actionButton().buttonStyle(.glass)
      }.padding().foregroundStyle(.secondary)
    }
  }

  /// Button which performs the action related to this ``Callout`` when triggered.
  private let actionButton: () -> ActionButton

  /// General explanation about or comment on the feature.
  private let title: () -> Title

  /// Details on how the feature works and, ideally, what the ``actionButton`` does.
  private let description: () -> Description

  /// Initializes a container with a hint for guiding the user toward the usage of a given feature
  /// of the application.
  ///
  /// - Parameters:
  ///   - actionButton: Button which performs the action related to this ``Callout`` when triggered.
  ///   - title: General explanation about or comment on the feature.
  ///   - description: Details on how the feature works and, ideally, what the `actionButton` does.
  init(
    @ViewBuilder actionButton: @escaping () -> ActionButton,
    @ViewBuilder title: @escaping () -> Title,
    @ViewBuilder description: @escaping () -> Description
  ) {
    self.actionButton = actionButton
    self.title = title
    self.description = description
  }
}
