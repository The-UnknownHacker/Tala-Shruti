//
//  Tala_ShrutiApp.swift
//  Tala Shruti
//
//  Created by Aarav J on 25/12/2024.
//

import SwiftUI

@main
struct Tala_ShrutiApp: App {
    @StateObject private var audioManager = AudioManager.shared
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var userDefaultsManager = UserDefaultsManager.shared
    
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
