//
//  AnyCodable.swift
//  LogStreamKitImp
//
//  Created by Hoang Nguyen on 12/11/25.
//

import Foundation

public struct AnyCodable: Codable {
  // MARK: Lifecycle

  public init(_ value: Any) {
    self.value = value
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if container.decodeNil() { value = NSNull() }
    else if let b = try? container.decode(Bool.self) { value = b }
    else if let i = try? container.decode(Int.self) { value = i }
    else if let d = try? container.decode(Double.self) { value = d }
    else if let s = try? container.decode(String.self) { value = s }
    else if let arr = try? container.decode([AnyCodable].self) { value = arr.map(\.value) }
    else if let dict = try? container.decode([String: AnyCodable].self) {
      var out = [String: Any]()
      for (k, v) in dict {
        out[k] = v.value
      }
      value = out
    } else {
      throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unsupported type")
    }
  }

  // MARK: Public

  public let value: Any

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    switch value {
    case is NSNull:
      try container.encodeNil()
    case let b as Bool:
      try container.encode(b)
    case let i as Int:
      try container.encode(i)
    case let d as Double:
      try container.encode(d)
    case let f as Float:
      try container.encode(Double(f))
    case let s as String:
      try container.encode(s)
    case let arr as [Any]:
      try container.encode(arr.map { AnyCodable($0) })
    case let dict as [String: Any]:
      var mapped = [String: AnyCodable]()
      for (k, v) in dict {
        mapped[k] = AnyCodable(v)
      }
      try container.encode(mapped)
    default:
      // fallback to string description
      try container.encode(String(describing: value))
    }
  }
}
