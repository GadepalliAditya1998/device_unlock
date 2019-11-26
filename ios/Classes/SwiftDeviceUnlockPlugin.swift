import Flutter
import UIKit
import LocalAuthentication

public class SwiftDeviceUnlockPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "device_unlock", binaryMessenger: registrar.messenger())
    let instance = SwiftDeviceUnlockPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
      case "request":
        guard let localizedReason = call.arguments as? String else {
          return
        }
        self.requestWithLocalizedReason(localizedReason, withResult: result)
        break
      case "gotoSettings":
        openSettings()
      break
      default:
        result(FlutterMethodNotImplemented)
    }
  }

  private func requestWithLocalizedReason(_ localizedReason: String, withResult flutterResult: @escaping FlutterResult) {
    let context = LAContext()
    var evaluationError: NSError?
    let policy: LAPolicy
    if #available(iOS 9, *) {
      policy = LAPolicy.deviceOwnerAuthentication
    } else {
      policy = LAPolicy.deviceOwnerAuthenticationWithBiometrics
    }

    if (!context.canEvaluatePolicy(policy, error: &evaluationError)) {
        if(evaluationError?.code == LAError.passcodeNotSet.rawValue) {
          // Since when passcode is not available no local auth is available, we can just consider this scenario
          let error = FlutterError(code: "DeviceUnlockUnavailable",
                                   message: evaluationError?.localizedDescription,
                                   details: evaluationError?.domain)
            flutterResult(error)
        }
    } else {
        context.evaluatePolicy(policy, localizedReason: localizedReason) { (success, error) in
            flutterResult(success)
        }
    }
  }

  private func openSettings() {
      if let url = URL(string: UIApplicationOpenSettingsURLString) {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
      }
  }

}
