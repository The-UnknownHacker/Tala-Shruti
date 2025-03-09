//
//  Tala_ShrutiApp.swift
//  Tala Shruti
//
//  Created by Aarav J on 25/12/2024.
//

import SwiftUI

// Combined AppDelegate to handle both orientation and feedback
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FeedbackManager.shared.incrementAppLaunches()
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        // Allow all orientations for iPad, but only portrait for iPhone
        if UIDevice.current.userInterfaceIdiom == .pad {
            return .all
        } else {
            return .portrait
        }
    }
}

@main
struct Tala_ShrutiApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var userDefaultsManager = UserDefaultsManager.shared
    
    var body: some Scene {
        WindowGroup {
            ShrutiBoxView()
                .onChange(of: scenePhase) { phase in
                    if phase == .background {
                        NotificationCenter.default.post(name: .savePreferences, object: nil)
                    }
                }
        }
    }
}
