import LogStreamKit
import SwiftUI

struct LogStreamKitDemoView: View {
  // MARK: Lifecycle

  init(logStreamKit: LogStreamKit) {
    self.logStreamKit = logStreamKit
  }

  // MARK: Internal

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("LogStreamKitDemo")
      Spacer()
    }
    .onAppear {
      logStreamKit.logEvent("video_play", params: ["video_id": "abc123", "duration_ms": 1200], level: .info)
      logStreamKit.logEvent("search", params: ["query": "funny dogs", "user_email": "test@example.com"], level: .debug)
      logStreamKit.logError(
        NSError(domain: "demo", code: 999, userInfo: [NSLocalizedDescriptionKey: "An example error"]),
        metadata: nil)
    }
    .onDisappear {
      // Flush before app backgrounding
      logStreamKit.flush { success in
        print("flush done: \(success)")
      }
    }
  }

  // MARK: Private

  private let logStreamKit: LogStreamKit
}
