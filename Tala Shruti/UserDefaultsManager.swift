import SwiftUI

extension Notification.Name {
    static let savePreferences = Notification.Name("savePreferences")
}

class UserDefaultsManager: ObservableObject {
    static let shared = UserDefaultsManager()
    
    private let defaults = UserDefaults.standard
    
    private let themeKey = "selectedTheme"
    private let colorSchemeKey = "colorScheme"
    private let madhyamamKey = "useMadhyamam"
    private let volumeKey = "volume"
    private let backgroundPlaybackKey = "backgroundPlayback"
    
    private init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleSavePreferences),
            name: .savePreferences,
            object: nil
        )
    }
    
    @objc private func handleSavePreferences() {
    }
    
    func savePreferences(theme: ThemeColor, colorScheme: ColorSchemeMode, 
                        useMadhyamam: Bool, volume: Double, 
                        backgroundPlayback: Bool) {
        defaults.set(theme.rawValue, forKey: themeKey)
        defaults.set(colorScheme.rawValue, forKey: colorSchemeKey)
        defaults.set(useMadhyamam, forKey: madhyamamKey)
        defaults.set(volume, forKey: volumeKey)
        defaults.set(backgroundPlayback, forKey: backgroundPlaybackKey)
    }
    
    func loadTheme() -> ThemeColor {
        guard let themeString = defaults.string(forKey: themeKey),
              let theme = ThemeColor(rawValue: themeString) else {
            return .blue 
        }
        return theme
    }
    
    func loadColorScheme() -> ColorSchemeMode {
        guard let modeString = defaults.string(forKey: colorSchemeKey),
              let mode = ColorSchemeMode(rawValue: modeString) else {
            return .system 
        }
        return mode
    }
    
    func loadMadhyamam() -> Bool {
        defaults.bool(forKey: madhyamamKey)
    }
    
    func loadVolume() -> Double {
        return defaults.double(forKey: volumeKey) == 0 ? 1.0 : defaults.double(forKey: volumeKey)
    }
    
    func loadBackgroundPlayback() -> Bool {
        return defaults.bool(forKey: backgroundPlaybackKey)
    }
} 