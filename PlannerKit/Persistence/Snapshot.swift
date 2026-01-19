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

/// Factory of copies of an `NSObject`.
///
/// `NSObject`s are mutable by nature. Their mutability allows for an amalgam of features, like
/// the reflection capabilities stemmed from Objective-C, whereas, e.g., the value of attributes
/// can be both retrieved and set according to their keys. Reference-typed instances such as these
/// provide extensive advantages.
///
/// However, they come at the cost of thread-safety: switching execution contexts while maintaining
/// references to instances of these types means that the instances are prone to mutations in other
/// contexts in which they may also be referenced, leading to potential race conditions and overall
/// inconsistent states.
///
/// Snapshots do not prevent mutations to the original object; rather, they store a copy of them,
/// whose state is that which they had by the time the snapshot was initialized. Whenever an
/// independent instance of the object in that original state needs to be produced, consumers can
/// call ``copy()`` and receive an instance *in that same state*, guaranteed to not have been
/// referenced by any other context prior to that call — not even by the snapshot itself.
struct Snapshot<Object>: @unchecked Sendable where Object: NSCopying & NSObjectProtocol {
  /// The original `NSObject`, in the same state in which it was when this ``Snapshot`` was
  /// initialized. This instance is *never* that returned by ``copy()``, because the function,
  /// instead, returns a copy of this instance.
  private let object: Object

  /// Initializes a ``Snapshot`` of an `NSObject`.
  ///
  /// - Parameter object: `NSObject` for which the ``Snapshot`` is.
  init(of object: Object) { self.object = object.copy() as! Object }

  /// Produces an independent, unreferenced copy of the original `NSObject`. The returned instance
  /// is guaranteed to be in the same state in which the original `NSObject` was by the time this
  /// ``Snapshot`` was initialized.
  func copy() -> Object { object.copy() as! Object }
}
