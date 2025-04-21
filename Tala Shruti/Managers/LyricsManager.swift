import Foundation
import SwiftUI

class LyricsManager: ObservableObject {
    static let shared = LyricsManager()
    
    @Published var userLyrics: [Lyrics] = []
    private let authManager = AuthManager.shared
    
    private init() {
        loadLyrics()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppBecameActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    @objc private func handleAppBecameActive() {
        print("LyricsManager: App became active, refreshing lyrics")
        loadLyrics()
    }
    
    func loadLyrics() {
        print("LyricsManager: Loading lyrics for user: \(authManager.userId)")
        guard !authManager.userId.isEmpty else {
            print("LyricsManager: No user ID, clearing lyrics")
            userLyrics = []
            return
        }
        
        if let data = UserDefaults.standard.data(forKey: "lyrics_\(authManager.userId)") {
            do {
                let decoder = JSONDecoder()
                self.userLyrics = try decoder.decode([Lyrics].self, from: data)
                print("LyricsManager: Successfully loaded \(userLyrics.count) lyrics")
            } catch {
                print("LyricsManager: Failed to decode lyrics: \(error)")
                self.userLyrics = []
            }
        } else {
            print("LyricsManager: No lyrics data found for user")
            self.userLyrics = []
        }
    }
    
    private func saveLyrics() {
        guard !authManager.userId.isEmpty else { 
            print("LyricsManager: Cannot save lyrics - no user ID")
            return 
        }
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(userLyrics)
            UserDefaults.standard.set(data, forKey: "lyrics_\(authManager.userId)")
            print("LyricsManager: Successfully saved \(userLyrics.count) lyrics")
        } catch {
            print("LyricsManager: Failed to encode lyrics: \(error)")
        }
    }
    
    func addLyrics(title: String, content: String, color: String) {
        guard !authManager.userId.isEmpty else { 
            print("LyricsManager: Cannot add lyrics - no user ID")
            return 
        }
        
        let newLyrics = Lyrics(
            title: title,
            content: content,
            userId: authManager.userId,
            color: color
        )
        
        userLyrics.append(newLyrics)
        saveLyrics()
        print("LyricsManager: Added new lyrics: \(title)")
    }
    
    func updateLyrics(id: String, title: String, content: String, color: String) {
        guard let index = userLyrics.firstIndex(where: { $0.id == id }) else { 
            print("LyricsManager: Cannot update lyrics - ID not found: \(id)")
            return 
        }
        
        userLyrics[index].title = title
        userLyrics[index].content = content
        userLyrics[index].color = color
        
        saveLyrics()
        print("LyricsManager: Updated lyrics: \(title)")
    }
    
    func deleteLyrics(id: String) {
        let countBefore = userLyrics.count
        userLyrics.removeAll { $0.id == id }
        
        if countBefore > userLyrics.count {
            saveLyrics()
            print("LyricsManager: Deleted lyrics with ID: \(id)")
        } else {
            print("LyricsManager: No lyrics found with ID: \(id)")
        }
    }
    
    func getLyrics(id: String) -> Lyrics? {
        return userLyrics.first { $0.id == id }
    }
    
    func refreshLyrics() {
        print("LyricsManager: Manually refreshing lyrics")
        loadLyrics()
    }
} 