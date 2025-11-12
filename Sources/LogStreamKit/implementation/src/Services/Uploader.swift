import Foundation
import Network

// MARK: - Uploader

public protocol Uploader: AnyObject {
  func scheduleIfNeeded()
  func flush(completion: @escaping (Bool) -> Void)
}

// MARK: - BatchingUploader

public final class BatchingUploader: Uploader, @unchecked Sendable {
  // MARK: Lifecycle

  public init(queue: LogQueue,
              serializer: LogSerializer,
              endpoint: URL,
              backgroundSessionIdentifier: String? = nil,
              batchSize: Int = 100,
              maxBatchBytes: Int = 256 * 1024,
              minInterval: TimeInterval = 5.0)
  {
    self.queue = queue
    self.serializer = serializer
    self.endpoint = endpoint
    self.batchSize = batchSize
    self.maxBatchBytes = maxBatchBytes
    self.minInterval = minInterval

    if let ident = backgroundSessionIdentifier {
      let config = URLSessionConfiguration.background(withIdentifier: ident)
      config.timeoutIntervalForRequest = 60
      config.waitsForConnectivity = true
      session = URLSession(configuration: config)
    } else {
      let config = URLSessionConfiguration.default
      config.timeoutIntervalForRequest = 60
      config.waitsForConnectivity = true
      session = URLSession(configuration: config)
    }
  }

  // MARK: Public

  public func scheduleIfNeeded() {
    workQueue.async { [weak self] in
      guard let self else { return }
      if self.isUploading { return }
      let count = self.queue.count()
      if count == 0 { return }
      if count >= self.batchSize || Date().timeIntervalSince(self.lastUpload) > self.minInterval {
        self.uploadBatch()
      }
    }
  }

  public func flush(completion: @escaping (Bool) -> Void) {
    workQueue.async { [weak self] in
      guard let self else { return }
      self.uploadBatch(completion: completion)
    }
  }

  // MARK: Private

  private let queue: LogQueue
  private let serializer: LogSerializer
  private let endpoint: URL
  private let session: URLSession
  private let batchSize: Int
  private let maxBatchBytes: Int
  private let maxAttempts = 5

  private var isUploading = false
  private let workQueue = DispatchQueue(label: "BatchingUploader.workQueue")
  private var lastUpload: Date = .distantPast
  private let minInterval: TimeInterval

  private func uploadBatch(completion: ((Bool) -> Void)? = nil) {
    guard !isUploading else { completion?(false)
      return
    }
    isUploading = true

    do {
      let batch = try queue.dequeueBatch(limit: batchSize, maxBytes: maxBatchBytes)
      guard !batch.isEmpty else {
        isUploading = false
        completion?(true)
        return
      }

      let datas = batch.map(\.data)
      let payload = serializer.wrapBatch(datas)
      var request = URLRequest(url: endpoint)
      request.httpMethod = "POST"
      request.setValue("application/json", forHTTPHeaderField: "Content-Type")
      request.httpBody = payload

      lastUpload = Date()

      let task = session.dataTask(with: request) { [weak self] _, response, _ in
        guard let self else { return }
        defer { self.isUploading = false }

        if let http = response as? HTTPURLResponse, 200 ... 299 ~= http.statusCode {
          // success -> delete ids
          let ids = batch.map(\.id)
          do { try self.queue.delete(items: ids) } catch { /* log */ }
          completion?(true)
        } else {
          // failure - decide requeue vs drop
          // For demo: we'll leave files in place (do nothing), but in robust system we'd increment attempt counter (stored in DB or sidecar file).
          // For basic retry: wait and call scheduleIfNeeded with exponential backoff
          self.retryLater()
          completion?(false)
        }
      }
      task.resume()
    } catch {
      isUploading = false
      completion?(false)
    }
  }

  private func retryLater() {
    workQueue.asyncAfter(deadline: .now() + 3.0) { [weak self] in
      self?.scheduleIfNeeded()
    }
  }
}
