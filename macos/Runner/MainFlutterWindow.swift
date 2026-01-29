import Cocoa
import FlutterMacOS
import SwiftUI
import NaturalLanguage
#if canImport(Translation)
import Translation
#endif

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)
    
    self.minSize = NSSize(width: 600, height: 400)

    RegisterGeneratedPlugins(registry: flutterViewController)

    let channel = FlutterMethodChannel(
      name: "lando/apple_translate",
      binaryMessenger: flutterViewController.engine.binaryMessenger
    )

    AppleTranslateBridge.shared.attach(to: flutterViewController)

    channel.setMethodCallHandler { call, result in
      print("[AppleTranslate macOS] method call: \(call.method)")
      guard call.method == "translate" else {
        print("[AppleTranslate macOS] unimplemented method")
        result(FlutterMethodNotImplemented)
        return
      }

      guard let args = call.arguments as? [String: Any],
            let text = args["text"] as? String,
            let to = args["to"] as? String else {
        print("[AppleTranslate macOS] bad_args: missing text/to, args=\(String(describing: call.arguments))")
        result(FlutterError(code: "bad_args", message: "Missing text/to", details: nil))
        return
      }

      let from = args["from"] as? String
      print("[AppleTranslate macOS] translate text length=\(text.count) from=\(from ?? "auto") to=\(to)")

      AppleTranslateBridge.shared.translate(
        text: text,
        from: from,
        to: to
      ) { translation, error in
        if let error = error {
          print("[AppleTranslate macOS] completion error: \(error.localizedDescription)")
          result(
            FlutterError(
              code: "translate_failed",
              message: error.localizedDescription,
              details: nil
            )
          )
          return
        }
        print("[AppleTranslate macOS] completion success, translation length=\(translation?.count ?? 0)")
        result(translation)
      }
    }

    super.awakeFromNib()
  }
}

// MARK: - Apple Translate (macOS) Bridge

private final class AppleTranslateBridge {
  static let shared = AppleTranslateBridge()

  #if canImport(Translation)
  private let worker: Any? = {
    if #available(macOS 15.0, *) {
      return AppleTranslateWorker()
    }
    return nil
  }()
  #endif

  private init() {}

  func attach(to parent: NSViewController) {
    print("[AppleTranslate macOS] attach called")
    #if canImport(Translation)
    if #available(macOS 15.0, *) {
      (worker as? AppleTranslateWorker)?.attach(to: parent)
    }
    #endif
  }

  func translate(
    text: String,
    from: String?,
    to: String,
    completion: @escaping (String?, Error?) -> Void
  ) {
    print("[AppleTranslate macOS] translate() entered")
#if canImport(Translation)
    if #available(macOS 15.0, *) {
      (worker as? AppleTranslateWorker)?.translate(
        text: text,
        from: from,
        to: to,
        completion: completion
      )
    } else {
      completion(nil, NSError(domain: "AppleTranslate", code: 1, userInfo: [
        NSLocalizedDescriptionKey: "Apple Translate requires macOS 15+"
      ]))
    }
#else
    completion(nil, NSError(domain: "AppleTranslate", code: 2, userInfo: [
      NSLocalizedDescriptionKey: "Translation framework not available"
    ]))
#endif
  }
}

#if canImport(Translation)

@available(macOS 15.0, *)
private final class AppleTranslateWorker {
  private var hostController: NSHostingController<AppleTranslateWorkerView>?
  private var translationPanel: NSPanel?
  private let model = AppleTranslateWorkerModel()

  func attach(to parent: NSViewController) {
    print("[AppleTranslate macOS] worker attach")
    guard hostController == nil else {
      print("[AppleTranslate macOS] worker already attached")
      return
    }

    let view = AppleTranslateWorkerView(model: model)
    let host = NSHostingController(rootView: view)
    host.view.wantsLayer = true
    host.view.layer?.backgroundColor = NSColor.clear.cgColor
    host.view.frame = NSRect(x: 0, y: 0, width: 10, height: 10)

    // Host the SwiftUI view in a dedicated transparent window so .translationTask runs.
    // When the view is hidden or in a zero-size container, the system may never run the task.
    let panel = NSPanel(
      contentRect: NSRect(x: 0, y: 0, width: 10, height: 10),
      styleMask: [.borderless],
      backing: .buffered,
      defer: false
    )
    panel.isOpaque = false
    panel.backgroundColor = .clear
    panel.hasShadow = false
    panel.level = .floating
    panel.collectionBehavior = [.canJoinAllSpaces, .stationary]
    panel.isReleasedWhenClosed = false
    panel.hidesOnDeactivate = false
    panel.contentViewController = host
    // Position off-screen so the user never sees it
    panel.setFrameOrigin(NSPoint(x: -10000, y: -10000))
    panel.orderFront(nil)
    translationPanel = panel
    hostController = host
    print("[AppleTranslate macOS] worker: hosting controller in transparent panel, panel ordered front")
  }

  func translate(
    text: String,
    from: String?,
    to: String,
    completion: @escaping (String?, Error?) -> Void
  ) {
    print("[AppleTranslate macOS] worker.translate()")
    model.start(text: text, from: from, to: to, completion: completion)
  }
}

@available(macOS 15.0, *)
private final class AppleTranslateWorkerModel: ObservableObject {
  @Published var configuration: TranslationSession.Configuration?
  @Published var textToTranslate: String?

  private var completion: ((String?, Error?) -> Void)?
  private var timeoutWorkItem: DispatchWorkItem?

  func start(
    text: String,
    from: String?,
    to: String,
    completion: @escaping (String?, Error?) -> Void
  ) {
    print("[AppleTranslate macOS] model.start() on main queue")
    timeoutWorkItem?.cancel()
    let timeoutItem = DispatchWorkItem { [weak self] in
      guard let self = self else { return }
      if let comp = self.completion {
        print("[AppleTranslate macOS] timeout: translationTask did not complete in time")
        comp(nil, NSError(domain: "AppleTranslate", code: 3, userInfo: [
          NSLocalizedDescriptionKey: "Translation timed out (translationTask may not run when view is hidden)"
        ]))
        self.reset()
      }
    }
    timeoutWorkItem = timeoutItem
    DispatchQueue.main.asyncAfter(deadline: .now() + 20, execute: timeoutItem)

    DispatchQueue.main.async {
      self.completion = completion
      self.textToTranslate = text

      let target = AppleTranslateWorkerModel.makeLanguage(identifier: to)
      var configSource: String?

      if let from = from, !from.isEmpty {
        let source = AppleTranslateWorkerModel.makeLanguage(identifier: from)
        self.configuration = TranslationSession.Configuration(source: source, target: target)
        configSource = from
      } else {
        let detected = AppleTranslateWorkerModel.detectLanguageCode(for: text)
        if let detected = detected {
          let source = AppleTranslateWorkerModel.makeLanguage(identifier: detected)
          self.configuration = TranslationSession.Configuration(source: source, target: target)
          configSource = "detected=\(detected)"
        } else {
          self.configuration = TranslationSession.Configuration(target: target)
          configSource = "auto"
        }
      }
      print("[AppleTranslate macOS] model: configuration set source=\(configSource ?? "nil") target=\(to), textToTranslate set")
    }
  }

  func finishSuccess(_ translated: String) {
    timeoutWorkItem?.cancel()
    timeoutWorkItem = nil
    print("[AppleTranslate macOS] model.finishSuccess length=\(translated.count)")
    completion?(translated, nil)
    reset()
  }

  func finishError(_ error: Error) {
    timeoutWorkItem?.cancel()
    timeoutWorkItem = nil
    print("[AppleTranslate macOS] model.finishError: \(error.localizedDescription)")
    completion?(nil, error)
    reset()
  }

  private func reset() {
    timeoutWorkItem?.cancel()
    timeoutWorkItem = nil
    completion = nil
    textToTranslate = nil
    configuration = nil
  }

  private static func detectLanguageCode(for text: String) -> String? {
    let recognizer = NLLanguageRecognizer()
    recognizer.processString(text)
    return recognizer.dominantLanguage?.rawValue
  }

  private static func makeLanguage(identifier: String) -> Locale.Language {
    // Normalize Chinese to avoid unsupported pairing like zh_TW -> zh_CN.
    // Prefer script-based identifiers: zh-Hans / zh-Hant.
    let normalized = identifier
      .replacingOccurrences(of: "_", with: "-")
      .trimmingCharacters(in: .whitespacesAndNewlines)

    switch normalized.lowercased() {
    case "zh", "zh-cn", "zh-hans":
      return Locale.Language(components: .init(languageCode: .init("zh"), script: .init("Hans"), region: nil))
    case "zh-hant", "zh-tw", "zh-hk":
      return Locale.Language(components: .init(languageCode: .init("zh"), script: .init("Hant"), region: nil))
    default:
      return Locale.Language(identifier: normalized)
    }
  }
}

@available(macOS 15.0, *)
private struct AppleTranslateWorkerView: View {
  @ObservedObject var model: AppleTranslateWorkerModel

  var body: some View {
    Color.clear
      .translationTask(model.configuration) { session in
        print("[AppleTranslate macOS] translationTask started, configuration=\(model.configuration != nil)")
        do {
          guard let text = model.textToTranslate else {
            print("[AppleTranslate macOS] translationTask: textToTranslate is nil, returning")
            return
          }
          print("[AppleTranslate macOS] session.translate() calling...")
          let response = try await session.translate(text)
          print("[AppleTranslate macOS] session.translate() returned length=\(response.targetText.count)")
          await MainActor.run {
            model.finishSuccess(response.targetText)
          }
        } catch {
          print("[AppleTranslate macOS] translationTask error: \(error)")
          await MainActor.run {
            model.finishError(error)
          }
        }
      }
  }
}

#endif
