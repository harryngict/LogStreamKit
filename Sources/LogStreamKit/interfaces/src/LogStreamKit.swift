
import Foundation

// MARK: - LogStreamKit

/// @mockable
public protocol LogStreamKit: AnyObject {
  func logEvent(_ name: String, params: [String: Any]?, level: LogLevel)
  func logError(_ error: Error, metadata: [String: Any]?)
  func flush(completion: @escaping (Bool) -> Void)
}
