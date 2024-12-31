//
//  Tala_ShrutiApp.swift
//  Tala Shruti
//
//  Created by Aarav J on 25/12/2024.
//

import SwiftUI

// Add AppDelegate to handle orientation locking
class AppDelegate: NSObject, UIApplicationDelegate {
    static var orientationLock = UIInterfaceOrientationMask.portrait
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
}

@main
struct Tala_ShrutiApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    @StateObject private var audioManager = AudioManager.shared
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var userDefaultsManager = UserDefaultsManager.shared
    
    init() {
        // Lock orientation to portrait
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
    }
    
    var body: some Scene {
        WindowGroup {
            ShrutiBoxView()
                .onChange(of: scenePhase) { phase in
                    if phase == .background {
                        // Save preferences when app goes to background
                        NotificationCenter.default.post(name: .savePreferences, object: nil)
                    }
                }
        }
    }
}
