// MIT License
//
// Copyright © 2021 John Sundell
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
// associated documentation files (the "Software"), to deal in the Software without restriction,
// including without limitation the rights to use, copy, modify, merge, publish, distribute,
// sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or
// substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
// NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

// MARK: - Map

public extension OwnedArray where Element: ~Copyable {
  /// Transform the sequence into an array of new values using an async closure.
  ///
  /// The closure calls will be performed in order, by waiting for each call to complete before
  /// proceeding with the next one. If any of the closure calls throw an error, then the iteration
  /// will be terminated and the error rethrown.
  ///
  /// - Parameter transform: The transform to run on each element.
  /// - Returns: The transformed values as an array. The order of the transformed values will match
  ///   the original sequence.
  /// - Throws: Rethrows any error thrown by the passed closure.
  func asyncMap<T>(
    _ transform: @Sendable (borrowing Element) async throws -> T
  ) async rethrows -> [T] {
    var transformations = unsafe [T](unsafeUninitializedCapacity: count) { _, _ in }
    var index = 0
    try await forEach { element in
      try await transformations[index] = transform(element)
      index += 1
    }
    return transformations
  }
}

public extension Sequence {
  /// Transform the sequence into an array of new values using an async closure.
  ///
  /// The closure calls will be performed in order, by waiting for each call to complete before
  /// proceeding with the next one. If any of the closure calls throw an error, then the iteration
  /// will be terminated and the error rethrown.
  ///
  /// - Parameter transform: The transform to run on each element.
  /// - Returns: The transformed values as an array. The order of the transformed values will match
  ///   the original sequence.
  /// - Throws: Rethrows any error thrown by the passed closure.
  func asyncMap<Result>(
    _ transform: (Element) async throws -> Result
  ) async rethrows -> [Result] {
    var iterator = makeIterator()
    return try await [Result?](count: underestimatedCount) { index in
      guard let element = iterator.next() else { return nil }
      return try await transform(element)
    } as! [Result]
  }
}
