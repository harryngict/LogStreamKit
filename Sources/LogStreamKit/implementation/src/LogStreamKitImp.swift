import Foundation
import UIKit
import LogStreamKit

// MARK: - LogStreamKitImp

public final class LogStreamKitImp: LogStreamKit, @unchecked Sendable {
  // MARK: Lifecycle

  public init(privacy: PrivacyEnforcer,
              sampler: Sampler,
              serializer: LogSerializer,
              queue: LogQueue,
              uploader: Uploader,
              endpoint: URL,
              sessionId: String? = nil)
  {
    self.privacy = privacy
    self.sampler = sampler
    self.serializer = serializer
    self.queue = queue
    self.uploader = uploader
    self.sessionId = sessionId

    deviceInfo = DeviceInfo(
      os: "iOS",
      osVersion: UIDevice.current.systemVersion,
      model: UIDevice.current.model,
      locale: Locale.current.identifier)
  }

  // MARK: Public

  public func logEvent(_ name: String, params: [String: Any]?, level: LogLevel) {
    guard privacy.allowLogging, sampler.shouldSample(event: name) else { return }
    logEntry(
      type: .event,
      name: name,
      params: params,
      level: level)
  }

  public func logError(_ error: any Error, metadata: [String: Any]?) {
    guard privacy.allowLogging else { return }
    logEntry(
      type: .error,
      name: String(describing: type(of: error)),
      params: metadata,
      level: .error)
  }

  public func flush(completion: @escaping (Bool) -> Void) {
    uploader.flush(completion: completion)
  }

  // MARK: Private

  private let privacy: PrivacyEnforcer
  private let sampler: Sampler
  private let serializer: LogSerializer
  private let deviceInfo: DeviceInfo
  private let queue: LogQueue
  private let uploader: Uploader
  private let sessionId: String?

  private func logEntry(type: LogType, name: String, params: [String: Any]?, level: LogLevel) {
    let scrubbedParams = privacy.scrub(params)?.mapValues { AnyCodable($0) }

    let entry = LogEntry(
      type: type,
      eventName: name,
      params: scrubbedParams,
      level: level.rawValue,
      device: deviceInfo,
      user: nil,
      sessionId: sessionId)

    do {
      let data = try serializer.serialize(entry: entry)
      try queue.append(data)
      uploader.scheduleIfNeeded()
    } catch {
      print("Logger error writing \(type): \(error)")
    }
  }
}
