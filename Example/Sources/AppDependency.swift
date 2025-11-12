import LogStreamKit

// MARK: - AppDependency

protocol AppDependency: AnyObject {
  var logStreamKit: LogStreamKit { get }
}

// MARK: - AppDependencyImp

final class AppDependencyImp: AppDependency {
  // MARK: Lifecycle

  init(logStreamKit: LogStreamKit) {
    self.logStreamKit = logStreamKit
  }

  // MARK: Internal

  let logStreamKit: LogStreamKit
}
