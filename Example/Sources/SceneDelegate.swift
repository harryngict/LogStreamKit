import CoreLocation
import LogStreamKit
import LogStreamKitImp
import SwiftUI

// MARK: - SceneDelegate

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  // MARK: Internal

  var window: UIWindow?

  func scene(_ scene: UIScene,
             willConnectTo session: UISceneSession,
             options connectionOptions: UIScene.ConnectionOptions)
  {
    guard let windowScene = (scene as? UIWindowScene) else { return }
    let window = UIWindow(windowScene: windowScene)

    let serializer = LogSerializerImp()
    let sampler = SamplerImp(samplingRates: [
      "crash": 1.0,
      "error": 1.0,
      "debug": 0.2,
      "ui_event": 0.05,
      "default": 0.1,
    ])
    let privacy = PrivacyEnforcerImp()
    let fileQueue = try! FileLogQueue(directoryName: "demo_logqueue")

    let endpoint = URL(string: "https://example.com/ingest/logs")! // replace with real endpoint
    let uploader = BatchingUploader(
      queue: fileQueue,
      serializer: serializer,
      endpoint: endpoint,
      backgroundSessionIdentifier: nil)

    let logStreamKit = LogStreamKitImp(
      privacy: privacy,
      sampler: sampler,
      serializer: serializer,
      queue: fileQueue,
      uploader: uploader,
      endpoint: endpoint,
      sessionId: "session-123")

    let dependency = AppDependencyImp(logStreamKit: logStreamKit)
    displayContentView(for: window, with: dependency)
  }

  func sceneDidEnterBackground(_ scene: UIScene) {}

  // MARK: Private

  private func displayContentView(for window: UIWindow,
                                  with dependency: AppDependency)
  {
    let contentView = ContentView(dependency: dependency)
    window.rootViewController = UIHostingController(rootView: contentView)
    self.window = window
    window.makeKeyAndVisible()
  }
}
