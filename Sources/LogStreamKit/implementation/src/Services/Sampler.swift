import Foundation

// MARK: - Sampler

public protocol Sampler {
  func shouldSample(event: String) -> Bool
}

// MARK: - SamplerImp

public final class SamplerImp: Sampler {
  // MARK: Lifecycle

  public init(samplingRates: [String: Double] = [:]) {
    self.samplingRates = samplingRates
  }

  // MARK: Public

  public func shouldSample(event: String) -> Bool {
    guard let rate = samplingRates[event] ?? samplingRates["default"] else {
      return true // log everything if not configured
    }
    return Double.random(in: 0 ... 1) <= rate
  }

  // MARK: Private

  private let samplingRates: [String: Double]
}
