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

import SwiftUI

#Preview { OnboardingCarousel(onNext: {}) }

public struct OnboardingCarousel: View {
  public var body: some View {
    ZStack {
      ScrollView(.horizontal) {
        ForEach(pages, id: \.self) { page in
          if let frame {
            page.frame(width: frame.width, height: frame.height)
          } else {
            page
          }
        }
      }
      Button(action: onNext) {
        Label {
          Text("Next")
        } icon: {
          Image(systemName: "arrow.right").fontWeight(.bold).imageScale(.large)
            .padding()
        }
      }
      .buttonStyle(.borderedProminent).buttonBorderShape(.circle).tint(.primary)
      .pagePadding([.trailing, .bottom])
      .containerRelativeFrame(.horizontal, alignment: .trailing)
      .containerRelativeFrame(.vertical, alignment: .bottom)
    }
    .coordinateSpace(.named(coordinateSpaceName))
    .onGeometryChange(for: CGRect?.self) { geometry in
      geometry.bounds(of: .named(coordinateSpaceName))
    } action: { newFrame in
      frame = newFrame
    }
  }

  private var coordinateSpaceName = UUID()

  @State
  private var frame: CGRect?

  private var pages: [IntroPage] { [.init()] }
  private var onNext: () -> Void

  public init(onNext: @escaping () -> Void) { self.onNext = onNext }
}
