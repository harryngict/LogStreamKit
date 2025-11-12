import Foundation

// MARK: - LogQueue

public protocol LogQueue {
  func append(_ data: Data) throws
  func dequeueBatch(limit: Int, maxBytes: Int) throws -> [(id: String, data: Data)]
  func delete(items: [String]) throws
  func count() -> Int
  func clear() throws
}

// MARK: - FileLogQueue

public final class FileLogQueue: LogQueue {
  // MARK: Lifecycle

  public init(directoryName: String = "logqueue") throws {
    let caches = try fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    dirURL = caches.appendingPathComponent(directoryName, isDirectory: true)
    try queue.sync {
      if !fileManager.fileExists(atPath: dirURL.path) {
        try fileManager.createDirectory(at: dirURL, withIntermediateDirectories: true, attributes: nil)
      }
    }
  }

  // MARK: Public

  public func append(_ data: Data) throws {
    try queue.sync {
      let id = UUID().uuidString
      let fileURL = dirURL.appendingPathComponent(id)
      try data.write(to: fileURL, options: .atomic)
    }
  }

  public func dequeueBatch(limit: Int, maxBytes: Int) throws -> [(id: String, data: Data)] {
    try queue.sync {
      let items = try fileManager.contentsOfDirectory(at: dirURL, includingPropertiesForKeys: [.creationDateKey], options: [.skipsHiddenFiles])
        .sorted { a, b -> Bool in
          let da = (try? a.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? Date.distantPast
          let db = (try? b.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? Date.distantPast
          return da < db
        }

      var out: [(String, Data)] = []
      var total = 0
      for file in items {
        if out.count >= limit { break }
        let data = try Data(contentsOf: file)
        if total + data.count > maxBytes { break }
        out.append((file.lastPathComponent, data))
        total += data.count
      }
      return out
    }
  }

  public func delete(items: [String]) throws {
    try queue.sync {
      for id in items {
        let fileURL = dirURL.appendingPathComponent(id)
        if fileManager.fileExists(atPath: fileURL.path) {
          try fileManager.removeItem(at: fileURL)
        }
      }
    }
  }

  public func count() -> Int {
    queue.sync {
      (try? fileManager.contentsOfDirectory(atPath: dirURL.path).count) ?? 0
    }
  }

  public func clear() throws {
    try queue.sync {
      let files = try fileManager.contentsOfDirectory(at: dirURL, includingPropertiesForKeys: nil, options: [])
      for f in files {
        try fileManager.removeItem(at: f)
      }
    }
  }

  // MARK: Private

  private let dirURL: URL
  private let fileManager = FileManager.default
  private let queue = DispatchQueue(label: "FileLogQueue.queue")
}
