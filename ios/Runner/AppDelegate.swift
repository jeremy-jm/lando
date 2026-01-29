import Flutter
import UIKit
import SwiftUI
import NaturalLanguage
#if canImport(Translation)
import Translation
#endif

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: "lando/apple_translate",
        binaryMessenger: controller.binaryMessenger
      )

      AppleTranslateBridge.shared.attach(to: controller)

      channel.setMethodCallHandler { call, result in
        print("[AppleTranslate iOS] method call: \(call.method)")
        guard call.method == "translate" else {
          print("[AppleTranslate iOS] unimplemented method")
          result(FlutterMethodNotImplemented)
          return
        }

        guard let args = call.arguments as? [String: Any],
              let text = args["text"] as? String,
              let to = args["to"] as? String else {
          print("[AppleTranslate iOS] bad_args: missing text/to, args=\(String(describing: call.arguments))")
          result(FlutterError(code: "bad_args", message: "Missing text/to", details: nil))
          return
        }

        let from = args["from"] as? String
        print("[AppleTranslate iOS] translate text length=\(text.count) from=\(from ?? "auto") to=\(to)")

        AppleTranslateBridge.shared.translate(
          text: text,
          from: from,
          to: to
        ) { translation, error in
          if let error = error {
            print("[AppleTranslate iOS] completion error: \(error.localizedDescription)")
            result(
              FlutterError(
                code: "translate_failed",
                message: error.localizedDescription,
                details: nil
              )
            )
            return
          }
          print("[AppleTranslate iOS] completion success, translation length=\(translation?.count ?? 0)")
          result(translation)
        }
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

// MARK: - Apple Translate (iOS) Bridge

private final class AppleTranslateBridge {
  static let shared = AppleTranslateBridge()

  private var hostController: UIHostingController<AppleTranslateWorkerView>?
  private let model = AppleTranslateWorkerModel()

  private init() {}

  func attach(to parent: UIViewController) {
    print("[AppleTranslate iOS] attach called")
    guard hostController == nil else {
      print("[AppleTranslate iOS] attach: already attached")
      return
    }

    let view = AppleTranslateWorkerView(model: model)
    let host = UIHostingController(rootView: view)
    host.view.backgroundColor = .clear
    // Non-zero frame so SwiftUI .translationTask runs (often skipped when frame is .zero)
    host.view.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
    host.view.isHidden = true

    parent.addChild(host)
    parent.view.addSubview(host.view)
    host.didMove(toParent: parent)

    hostController = host
    print("[AppleTranslate iOS] attach: hosting controller added")
  }

  func translate(
    text: String,
    from: String?,
    to: String,
    completion: @escaping (String?, Error?) -> Void
  ) {
    print("[AppleTranslate iOS] translate() entered")
#if canImport(Translation)
    if #available(iOS 18.0, *) {
      model.start(text: text, from: from, to: to, completion: completion)
    } else {
      completion(nil, NSError(domain: "AppleTranslate", code: 1, userInfo: [
        NSLocalizedDescriptionKey: "Apple Translate requires iOS 18+"
      ]))
    }
#else
    completion(nil, NSError(domain: "AppleTranslate", code: 2, userInfo: [
      NSLocalizedDescriptionKey: "Translation framework not available"
    ]))
#endif
  }
}

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
    print("[AppleTranslate iOS] model.start() on main queue")
    timeoutWorkItem?.cancel()
    let timeoutItem = DispatchWorkItem { [weak self] in
      guard let self = self else { return }
      if let comp = self.completion {
        print("[AppleTranslate iOS] timeout: translationTask did not complete in time")
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
      print("[AppleTranslate iOS] model: configuration set source=\(configSource ?? "nil") target=\(to), textToTranslate set")
    }
  }

  func finishSuccess(_ translated: String) {
    timeoutWorkItem?.cancel()
    timeoutWorkItem = nil
    print("[AppleTranslate iOS] model.finishSuccess length=\(translated.count)")
    completion?(translated, nil)
    reset()
  }

  func finishError(_ error: Error) {
    timeoutWorkItem?.cancel()
    timeoutWorkItem = nil
    print("[AppleTranslate iOS] model.finishError: \(error.localizedDescription)")
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

    if normalized.lowercased() == "zh" || normalized.lowercased() == "zh-cn" {
      return Locale.Language(components: .init(languageCode: .init("zh"), script: .init("Hans"), region: nil))
    }
    if normalized.lowercased() == "zh-hans" {
      return Locale.Language(components: .init(languageCode: .init("zh"), script: .init("Hans"), region: nil))
    }
    if normalized.lowercased() == "zh-hant" || normalized.lowercased() == "zh-tw" || normalized.lowercased() == "zh-hk" {
      return Locale.Language(components: .init(languageCode: .init("zh"), script: .init("Hant"), region: nil))
    }

    return Locale.Language(identifier: normalized)
  }
}

private struct AppleTranslateWorkerView: View {
  @StateObject var model: AppleTranslateWorkerModel

  var body: some View {
    Color.clear
      .translationTask(model.configuration) { session in
        print("[AppleTranslate iOS] translationTask started, configuration=\(model.configuration != nil)")
        do {
          guard let text = model.textToTranslate else {
            print("[AppleTranslate iOS] translationTask: textToTranslate is nil, returning")
            return
          }
          print("[AppleTranslate iOS] session.translate() calling...")
          let response = try await session.translate(text)
          print("[AppleTranslate iOS] session.translate() returned length=\(response.targetText.count)")
          await MainActor.run {
            model.finishSuccess(response.targetText)
          }
        } catch {
          print("[AppleTranslate iOS] translationTask error: \(error)")
          await MainActor.run {
            model.finishError(error)
          }
        }
      }
  }
}
