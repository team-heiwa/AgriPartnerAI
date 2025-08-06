import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Configure Google Maps API key
    GMSServices.provideAPIKey("AIzaSyBwEFUaNVc-HufJghr12pMTrENd67gpwtA")
    
    GeneratedPluginRegistrant.register(with: self)
    
    // デバッグログを追加
    print("🎯 AppDelegate: Registering custom plugins...")
    
    // GemmaCoreMLPlugin の登録
    if #available(iOS 16.0, *) {
        if let registrar = self.registrar(forPlugin: "GemmaCoreMLPlugin") {
            print("📌 Registering GemmaCoreMLPlugin")
            GemmaCoreMLPlugin.register(with: registrar)
        } else {
            print("❌ Failed to get registrar for GemmaCoreMLPlugin")
        }
    }
    
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
