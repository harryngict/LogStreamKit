import Foundation

// MARK: - LogSerializer

public protocol LogSerializer {
  func serialize(entry: LogEntry) throws -> Data
  func wrapBatch(_ items: [Data]) -> Data
}

// MARK: - LogSerializerImp

public final class LogSerializerImp: LogSerializer {
  // MARK: Lifecycle

  public init() {
    encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
  }

  // MARK: Public

  public func serialize(entry: LogEntry) throws -> Data {
    try encoder.encode(entry)
  }

  public func wrapBatch(_ items: [Data]) -> Data {
    // For each item we already have encoded JSON (LogEntry). We'll create wrapper: {"events": [obj1, obj2...]}
    // Simpler to join as JSON array
    let arrayData = "[" + items.map { String(data: $0, encoding: .utf8) ?? "{}" }.joined(separator: ",") + "]"
    return Data(arrayData.utf8)
  }

  // MARK: Private

  private let encoder: JSONEncoder
}
