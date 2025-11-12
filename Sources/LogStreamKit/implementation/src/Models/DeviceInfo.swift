import Foundation
import LogStreamKit

// MARK: - LogType

public enum LogType: String, Codable {
  case event
  case error
  case metric
  case breadcrumb
}

// MARK: - DeviceInfo

public struct DeviceInfo: Codable {
  public let os: String
  public let osVersion: String
  public let model: String
  public let locale: String
}

// MARK: - UserInfo

public struct UserInfo: Codable {
  public let userId: String?
  public let anonId: String
}

// MARK: - LogEntry

public struct LogEntry: Codable {
  // MARK: Lifecycle

  public init(version: String = "1.0",
              id: String = UUID().uuidString,
              type: LogType,
              timestamp: Date = Date(),
              eventName: String? = nil,
              params: [String: AnyCodable]? = nil,
              level: String? = nil,
              device: DeviceInfo,
              user: UserInfo? = nil,
              sessionId: String? = nil)
  {
    self.version = version
    self.id = id
    self.type = type
    self.timestamp = timestamp
    self.eventName = eventName
    self.params = params
    self.level = level
    self.device = device
    self.user = user
    self.sessionId = sessionId
  }

  // MARK: Public

  public let version: String
  public let id: String
  public let type: LogType
  public let timestamp: Date
  public let eventName: String?
  public let params: [String: AnyCodable]?
  public let level: String?
  public let device: DeviceInfo
  public let user: UserInfo?
  public let sessionId: String?
}
