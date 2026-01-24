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

/// Type-erased version of the instance of some type conforming to the `Codable` protocol.
///
/// ## Limitations
///
/// Because this implementation is specific to Pragma and its use cases, not all codables can have
/// their type erased. In fact, due to the ID of every implementation of plan, goal and to-do being
/// a UUID, that is the only supported type; an instance of any other codable being wrapped by this
/// struct will throw upon encoding or decoding.
struct AnyCodable: @unchecked Sendable {
  /// Codable whose type has been erased by this wrapper.
  let base: AnyHashable

  /// Original type of the ``base``, erased by this wrapper.
  let erasedType: Any.Type

  init<Base>(_ base: Base) where Base: Codable & Hashable & Sendable {
    self.base = base
    self.erasedType = Base.Type.self
  }
}

extension AnyCodable: CustomStringConvertible {
  public var description: String { base.description }
}

extension AnyCodable: Encodable {
  public func encode(to encoder: any Encoder) throws {
    switch base {
    case let base as UUID: try base.encode(to: encoder)
    default:
      throw EncodingError.invalidValue(
        base,
        .init(
          codingPath: encoder.codingPath,
          debugDescription: "Encoding of type-erased \(erasedType) (\(base)) is unsupported."
        )
      )
    }
  }
}

extension AnyCodable: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool { lhs.base == rhs.base }
}

extension AnyCodable: Decodable {
  public init(from decoder: any Decoder) throws {
    guard let base = try? UUID(from: decoder) else {
      throw DecodingError.typeMismatch(
        UUID.self,
        .init(
          codingPath: decoder.codingPath,
          debugDescription: "Attempted to decode value of non-erasable type."
        )
      )
    }
    self = .init(base)
  }
}

extension AnyCodable: Hashable {
  public func hash(into hasher: inout Hasher) { base.hash(into: &hasher) }
}
