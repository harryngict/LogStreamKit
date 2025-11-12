import SwiftUI

// MARK: - ContentView

struct ContentView: View {
  // MARK: Lifecycle

  init(dependency: AppDependency) {
    self.dependency = dependency
  }

  // MARK: Internal

  var body: some View {
    NavigationView {
      List {
        NavigationLink(
          destination: LogStreamKitDemoView(
            logStreamKit: dependency.logStreamKit)
        ) {
          Text("Tap to open LogStreamKitDemoView")
        }
      }
      .navigationTitle("Demo")
    }
  }

  // MARK: Private

  private let dependency: AppDependency
}
