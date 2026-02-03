// ===-------------------------------------------------------------------------------------------===
// Copyright © 2025 Apple Inc. and the Swift project authors
//
// This source file is part of the Swift MMIO open source project.
//
// Licensed under Apache License v2.0 with Runtime Library Exception.
//
// See https://swift.org/LICENSE.txt for license information.
//
// ===-------------------------------------------------------------------------------------------===

// Copyright © 2026 Jean Silva
// Pragma-specific changes:
//
// - Added an initializer allowing to specify the initial capacity;
// - Added a random-access- and range-replaceable-collection-like API:
//   - first(where:)        → withFirst(where:_:);
//   - firstIndex(where:)   → firstIndex(where:);
//   - forEach(_:)          → forEach(_:);
//   - remove(at:)          → remove(at:);
//   - removeAll()          → removeAll(); and
//   - subscript(position:) → withElement(at:_:);
// - checked whether the buffer exists before deinitializing its memory and deallocating it;
// - conformed to `Sendable` conditionally;
// - declared deinitializer lastly;
// - made the buffer private;
// - marked `OwnedArray` type as safe;
// - marked unsafe expressions as unsafe;
// - renamed `push(_:)` to "append";
// - removed `pop()`;
// - removed "self." prefix from accesses to members;
// - replaced consuming subscript by borrowing `withElement(at:_:)`; and
// - replaced `_count` by `count`, with a public getter and a private setter.

@safe
public struct OwnedArray<Element: ~Copyable>: ~Copyable {
  /// The number of elements in this array.
  public private(set) var count = 0

  /// Backing storage of this array.
  private var buffer: UnsafeMutableBufferPointer<Element>?

  /// Initializes an empty ``OwnedArray``.
  public init() {
    unsafe self.buffer = nil
  }

  /// Initializes an empty ``OwnedArray`` with an initial capacity.
  ///
  /// - Parameter capacity: Minimum amount of elements that the array is expected to contain. Its
  ///   capacity will grow in case a number of elements greater than this specified amount is
  ///   appended.
  /// - SeeAlso: ``append(_:)``
  public init(capacity: Int) {
    unsafe self.buffer = .allocate(capacity: capacity)
  }

  deinit {
    guard let buffer = unsafe buffer else { return }
    unsafe buffer.extracting(..<self.count).deinitialize()
    unsafe buffer.deallocate()
  }
}

// MARK: - Sequence-like API

public extension OwnedArray where Element: ~Copyable {
  /// Returns the first index in which an element of this array satisfies the given predicate.
  ///
  /// You can use the predicate to find an element of a type that doesn't conform to the `Equatable`
  /// protocol or to find an element that matches particular criteria. Here's an example that finds
  /// a student name that begins with the letter "A":
  ///
  /// ```swift
  /// var students = OwnedArray<String>(capacity: 5)
  /// students.append("Kofi")
  /// students.append("Abena")
  /// students.append("Peter")
  /// students.append("Kweku")
  /// students.append("Akosua")
  /// if let i = students.firstIndex(where: { $0.hasPrefix("A") }) {
  ///   print("\(students[i]) starts with 'A'!")
  /// }
  /// // Prints "Abena starts with 'A'!"
  /// ```
  ///
  /// - Complexity: O(*n*), where *n* is the length of the array.
  /// - Parameter predicate: A closure that takes an element as its argument and returns a Boolean
  ///   value that indicates whether the passed element represents a match.
  /// - Returns: The index of the first element for which `predicate` returns `true`. If no elements
  ///   in this array satisfy the given predicate, returns `nil`.
  borrowing func firstIndex(where predicate: (borrowing Element) throws -> Bool) rethrows -> Int? {
    for index in indices {
      guard let isMatch = try withElement(at: index, predicate), isMatch else { continue }
      return index
    }
    return nil
  }

  /// Returns an array containing the results of mapping the given closure over the array's
  /// elements.
  ///
  /// In this example, `map` is used first to convert the names in the array to lowercase strings
  /// and then to count their characters.
  ///
  /// ```swift
  /// var cast = OwnedArray<String>()
  /// cast.append("Vivien")
  /// cast.append("Marlon")
  /// cast.append("Kim")
  /// cast.append("Karl")
  /// let lowercaseNames = cast.map { $0.lowercased() }
  /// // 'lowercaseNames' == ["vivien", "marlon", "kim", "karl"]
  /// let letterCounts = cast.map { $0.count }
  /// // 'letterCounts' == [6, 6, 3, 4]
  /// ```
  ///
  /// - Parameter transform: A mapping closure. `transform` accepts an element of this array as its
  ///   parameter and returns a transformed value of the same or of a different type.
  /// - Returns: An array containing the transformed elements of this array.
  borrowing func map<Result>(
    _ transform: (borrowing Element) throws -> Result
  ) rethrows -> [Result] {
    var transformations = unsafe [Result](unsafeUninitializedCapacity: count) { _, _ in }
    var index = 0
    try forEach { element in
      try transformations[index] = transform(element)
      index += 1
    }
    return transformations
  }

  // MARK: forEach(_:)

  /// Calls the given closure on each element in this array in the same order as a `for`-`in` loop.
  ///
  /// The two loops in the following example produce the same output:
  ///
  /// ```swift
  /// let numberWords1 = ["one", "two", "three"]
  /// for word in numberWords { print(word) }
  /// // Prints "one"
  /// // Prints "two"
  /// // Prints "three"
  ///
  /// var numberWords2 = OwnedArray<String>()
  /// numberWords2.append("one")
  /// numberWords2.append("two")
  /// numberWords2.append("three")
  /// numberWords.forEach(print)
  /// // Same as above
  /// ```
  ///
  /// Using the `forEach` method is distinct from a `for`-`in` loop on an instance conforming to
  /// `Sequence` in two important ways:
  ///
  /// 1. You cannot use a `break` or `continue` statement to exit the current call of the `body`
  ///    closure or skip subsequent calls; and
  /// 2. using the `return` statement in the `body` closure will exit only from the current call to
  ///    `body`, not from any outer scope, and won't skip subsequent calls.
  ///
  /// - Parameter body: A closure that takes an element of this array as a parameter.
  borrowing func forEach(_ body: (borrowing Element) throws -> Void) rethrows {
    for index in indices { try withElement(at: index, body) }
  }

  /// Calls the given closure on each element in this array in the same order as a `for`-`in` loop.
  ///
  /// The two loops in the following example produce the same output:
  ///
  /// ```swift
  /// let numberWords1 = ["one", "two", "three"]
  /// for word in numberWords { print(word) }
  /// // Prints "one"
  /// // Prints "two"
  /// // Prints "three"
  ///
  /// var numberWords2 = OwnedArray<String>()
  /// numberWords2.append("one")
  /// numberWords2.append("two")
  /// numberWords2.append("three")
  /// numberWords.forEach(print)
  /// // Same as above
  /// ```
  ///
  /// Using the `forEach` method is distinct from a `for`-`in` loop on an instance conforming to
  /// `Sequence` in two important ways:
  ///
  /// 1. You cannot use a `break` or `continue` statement to exit the current call of the `body`
  ///    closure or skip subsequent calls; and
  /// 2. using the `return` statement in the `body` closure will exit only from the current call to
  ///    `body`, not from any outer scope, and won't skip subsequent calls.
  ///
  /// - Parameter body: A closure that takes an element of this array as a parameter.
  borrowing func forEach(_ body: (borrowing Element) async throws -> Void) async rethrows {
    for index in indices { try await withElement(at: index, body) }
  }
}

public extension OwnedArray where Element: ~Copyable {
  // MARK: withFirst(where:_)

  /// Performs an operation with the first element of this array that satisfies the given predicate.
  ///
  /// The following example uses the ``withFirst`(where:_:)`` method to find the first negative
  /// number in an array of integers:
  ///
  /// ```swift
  /// var numbers = OwnedArray(capacity: 8)
  /// numbers.append(3)
  /// numbers.append(7)
  /// numbers.append(4)
  /// numbers.append(-2)
  /// numbers.append(9)
  /// numbers.append(-6)
  /// numbers.append(10)
  /// numbers.append(1)
  /// withFirst(where: { $0 < 0 }) { firstNegative in
  ///   print("The first negative number is \(firstNegative).")
  /// }
  /// // Prints "The first negative number is -2."
  /// ```
  ///
  /// - Complexity: O(*n*), where *n* is the length of the array.
  /// - Parameters:
  ///   - predicate: A closure that takes an element of this array as its argument and returns a
  ///     Boolean value indicating whether the element is a match.
  ///   - action: Operation performed with the element that matched the `predicate`.
  /// - Returns: The result of having called the `action`; or `nil` if no element matching the
  ///   `predicate` was found in this array.
  borrowing func withFirst<Result>(
    where predicate: (borrowing Element) -> Bool,
    _ action: (borrowing Element) throws -> Result
  ) rethrows -> Result? {
    for index in indices {
      guard
        let result = try withElement(
          at: index,
          { element in predicate(element) ? try action(element) : nil }
        )
      else { continue }
      return result
    }
    return nil
  }

  /// Performs an operation with the first element of this array that satisfies the given predicate.
  ///
  /// The following example uses the ``withFirst`(where:_:)`` method to find the first negative
  /// number in an array of integers:
  ///
  /// ```swift
  /// var numbers = OwnedArray(capacity: 8)
  /// numbers.append(3)
  /// numbers.append(7)
  /// numbers.append(4)
  /// numbers.append(-2)
  /// numbers.append(9)
  /// numbers.append(-6)
  /// numbers.append(10)
  /// numbers.append(1)
  /// withFirst(where: { $0 < 0 }) { firstNegative in
  ///   print("The first negative number is \(firstNegative).")
  /// }
  /// // Prints "The first negative number is -2."
  /// ```
  ///
  /// - Complexity: O(*n*), where *n* is the length of the array.
  /// - Parameters:
  ///   - predicate: A closure that takes an element of this array as its argument and returns a
  ///     Boolean value indicating whether the element is a match.
  ///   - action: Operation performed with the element that matched the `predicate`.
  /// - Returns: The result of having called the `action`; or `nil` if no element matching the
  ///   `predicate` was found in this array.
  borrowing func withFirst<Result>(
    where predicate: (borrowing Element) -> Bool,
    _ action: (borrowing Element) async throws -> Result
  ) async rethrows -> Result? {
    for index in indices {
      guard
        let result = try await withElement(
          at: index,
          { element in predicate(element) ? try await action(element) : nil }
        )
      else { continue }
      return result
    }
    return nil
  }
}

extension OwnedArray: @unchecked Sendable where Element: Sendable {}

// MARK: - Collection-like API

extension OwnedArray where Element: ~Copyable {
  /// The total number of elements that this array can contain without allocating new storage.
  ///
  /// Every array reserves a specific amount of memory to hold its contents. When you add elements
  /// to an array and that array begins to exceed its reserved capacity, the array allocates a
  /// larger region of memory and copies its elements into the new storage. The new storage is a
  /// multiple of the old storage's size. This exponential growth strategy means that appending an
  /// element happens in constant time, averaging the performance of many append operations. Append
  /// operations that trigger reallocation have a performance cost, but they occur less and less
  /// often as the array grows larger.
  ///
  /// The following example creates an array of integers from the initializer that allows for
  /// specifying the initial capacity; then, appends the elements of another collection. Before
  /// appending, the array allocates new storage that is large enough store the resulting elements.
  ///
  /// ```swift
  ///  var numbers = OwnedArray<Int>(capacity: 5)
  ///  numbers.append(10)
  ///  numbers.append(20)
  ///  numbers.append(30)
  ///  numbers.append(40)
  ///  numbers.append(50)
  ///  // numbers.count == 5
  ///  // numbers.capacity == 5
  ///
  /// numbers.append(contentsOf: stride(from: 60, through: 100, by: 10))
  /// // numbers.count == 10
  /// // numbers.capacity == 10
  /// ```
  public var capacity: Int { unsafe self.buffer?.count ?? 0 }

  /// A Boolean value indicating whether this array is empty.
  ///
  /// - Complexity: O(1).
  public var isEmpty: Bool { self.count == 0 }

  /// The indices that are valid for obtaining elements in this array, in ascending order.
  ///
  /// - SeeAlso: ``withElement(at:_:)``
  public var indices: Range<Int> { 0..<self.count }
}

// MARK: - RandomAccessCollection-like API

extension OwnedArray where Element: ~Copyable {
  // MARK: withElement(at:_:)

  /// Performs an operation with the borrowed element at the specified position.
  ///
  /// - Complexity: O(1).
  /// - Parameter index: The position of the element to access. `index` must be greater than or
  ///   equal to zero and less than ``count``.
  public func withElement<Result>(
    at index: Int,
    _ action: (borrowing Element) throws -> Result
  ) rethrows -> Result? {
    try withMutableElement(at: index) { element in try action(element) }
  }

  /// Performs an operation with the borrowed element at the specified position.
  ///
  /// - Complexity: O(1).
  /// - Parameter index: The position of the element to access. `index` must be greater than or
  ///   equal to zero and less than ``count``.
  public func withElement<Result>(
    at index: Int,
    _ action: (borrowing Element) async throws -> Result
  ) async rethrows -> Result? {
    try await withMutableElement(at: index) { element in try await action(element) }
  }

  // MARK: withMutableElement(at:_:)

  /// Performs an operation with the mutable element at the specified position.
  ///
  /// - Complexity: O(1).
  /// - Parameter index: The position of the element to access. `index` must be greater than or
  ///   equal to zero and less than ``count``.
  public func withMutableElement<Result>(
    at index: Int,
    _ action: (inout Element) throws -> Result
  ) rethrows -> Result? {
    guard let buffer = unsafe buffer else { return nil }
    var element = unsafe buffer.moveElement(from: index)
    let result = try action(&element)
    unsafe buffer.initializeElement(at: index, to: element)
    return result
  }

  /// Performs an operation with the mutable element at the specified position.
  ///
  /// - Complexity: O(1).
  /// - Parameter index: The position of the element to access. `index` must be greater than or
  ///   equal to zero and less than ``count``.
  public func withMutableElement<Result>(
    at index: Int,
    _ action: (inout Element) async throws -> Result
  ) async rethrows -> Result? {
    guard let buffer = unsafe buffer else { return nil }
    var element = unsafe buffer.moveElement(from: index)
    let result = try await action(&element)
    unsafe buffer.initializeElement(at: index, to: element)
    return result
  }
}

// MARK: - RangeReplaceableCollection-like API

extension OwnedArray where Element: ~Copyable {
  /// Adds a new element at the end of this array.
  ///
  /// Use this method to append a single element to the end of a mutable array.
  ///
  /// ```swift
  /// var numbers = OwnedArray<Int>()
  /// numbers.append(1)
  /// numbers.append(2)
  /// numbers.append(3)
  /// numbers.append(4)
  /// numbers.append(5)
  /// numbers.append(100)
  /// print(numbers)
  /// // Prints "[1, 2, 3, 4, 5, 100]"
  /// ```
  ///
  /// Because arrays increase their allocated capacity using an exponential strategy, appending a
  /// single element to an array is an O(1) operation when averaged over many calls to the
  /// ``append(_:)`` method. When an array has additional capacity and is not sharing its storage
  /// with another instance, appending an element is O(1). When an array needs to reallocate storage
  /// before appending or its storage is shared with another copy, appending is O(*n*), where *n* is
  /// the length of the array.
  ///
  /// - Complexity: O(1) on average, over many calls to ``append(_:)`` on this array.
  /// - Parameter newElement: The element to append to this array.
  public mutating func append(_ newElement: consuming Element) {
    if count == capacity {
      if let oldBuffer = unsafe buffer {
        let newBuffer = UnsafeMutableBufferPointer<Element>.allocate(
          capacity: oldBuffer.count * 2
        )
        _ = unsafe newBuffer.moveInitialize(fromContentsOf: oldBuffer)
        unsafe oldBuffer.deallocate()
        unsafe buffer = newBuffer
      } else {
        unsafe buffer = .allocate(capacity: 4)
      }
    }
    unsafe buffer?.initializeElement(at: self.count, to: newElement)
    count += 1
  }

  /// Removes and returns the element at the specified position.
  ///
  /// All the elements following the specified position are moved up to close the gap.
  ///
  /// ```swift
  /// var measurements = OwnedArray<Double>(capacity: 7)
  /// measurements.append(1.1)
  /// measurements.append(1.5)
  /// measurements.append(2.9)
  /// measurements.append(1.2)
  /// measurements.append(1.5)
  /// measurements.append(1.3)
  /// measurements.append(1.2)
  /// let removed = measurements.remove(at: 2)
  /// print(measurements)
  /// // Prints "[1.1, 1.5, 1.2, 1.5, 1.3, 1.2]"
  /// ```
  ///
  /// - Complexity: O(*n*), where *n* is the length of this array.
  /// - Parameter index: The position of the element to remove. `index` must be a valid index of
  ///   this array.
  /// - Returns: The element at the specified index.
  @discardableResult
  public mutating func remove(at index: Int) -> Element? {
    guard let buffer = unsafe buffer, self.count > 0 else { return nil }
    let element = unsafe buffer.moveElement(from: index)
    self.count -= 1
    return element
  }

  /// Removes all elements from this array, not keeping its existing capacity.
  public mutating func removeAll() {
    guard let buffer = unsafe buffer, self.count > 0 else { return }
    unsafe buffer.extracting(0..<count).deinitialize()
    unsafe buffer.deallocate()
    unsafe self.buffer = nil
  }
}
