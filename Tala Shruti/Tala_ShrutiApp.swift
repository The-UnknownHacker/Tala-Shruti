//
//  Tala_ShrutiApp.swift
//  Tala Shruti
//
//  Created by Aarav J on 25/12/2024.
//

import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FeedbackManager.shared.incrementAppLaunches()
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
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
    @StateObject private var authManager = AuthManager.shared
    @StateObject private var lyricsManager = LyricsManager.shared
    @AppStorage("hasSeenLanding") private var hasSeenLanding = false
    @State private var showLanding = false
    
    var body: some Scene {
        WindowGroup {
            Group {
                if !hasSeenLanding {
                    LandingView()
                        .onAppear {
                            print("Tala_ShrutiApp: Showing LandingView - hasSeenLanding: \(hasSeenLanding), isAuthenticated: \(authManager.isAuthenticated)")
                        }
                } else if authManager.isAuthenticated {
                    ContentView()
                        .onAppear {
                            print("Tala_ShrutiApp: Showing ContentView - hasSeenLanding: \(hasSeenLanding), isAuthenticated: \(authManager.isAuthenticated)")
                        }
                } else {
                    LandingView()
                        .onAppear {
                            print("Tala_ShrutiApp: Showing LandingView (not authenticated) - hasSeenLanding: \(hasSeenLanding), isAuthenticated: \(authManager.isAuthenticated)")
                        }
                }
            }
            .onAppear {
                print("Tala_ShrutiApp: App appeared - hasSeenLanding: \(hasSeenLanding), isAuthenticated: \(authManager.isAuthenticated)")
                if !hasSeenLanding {
                    showLanding = true
                }
            }
        }
    }
}
