import Foundation

// MARK: - PrivacyEnforcer

public protocol PrivacyEnforcer {
  var allowLogging: Bool { get }
  var scrubEmail: Bool { get }

  func scrub(_ dict: [String: Any]?) -> [String: Any]?
}

// MARK: - PrivacyEnforcerImp

public final class PrivacyEnforcerImp: PrivacyEnforcer {
  // MARK: Lifecycle

  public init(allowLogging: Bool = true,
              scrubEmail: Bool = true)
  {
    self.allowLogging = allowLogging
    self.scrubEmail = scrubEmail
  }

  // MARK: Public

  public let allowLogging: Bool
  public let scrubEmail: Bool

  public func scrub(_ dict: [String: Any]?) -> [String: Any]? {
    guard let dict else { return nil }
    var out = [String: Any]()
    for (k, v) in dict {
      if scrubEmail, let s = v as? String, s.contains("@") {
        out[k] = hash(string: s)
      } else {
        out[k] = v
      }
    }
    return out
  }

  // MARK: Private

  private func hash(string: String) -> String {
    String(string.hashValue)
  }
}
