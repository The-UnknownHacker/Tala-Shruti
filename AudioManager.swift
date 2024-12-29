import Foundation
import AVFoundation

class AudioManager: ObservableObject {
    static let shared = AudioManager()
    
    private init() {
        setupAudioSession()
    }
    
    func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
            
            // Enable background playback
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default,
                policy: .longFormAudio
            )
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    func enableBackgroundPlayback(_ enabled: Bool) {
        do {
            if enabled {
                try AVAudioSession.sharedInstance().setCategory(
                    .playback,
                    mode: .default,
                    policy: .longFormAudio
                )
            } else {
                try AVAudioSession.sharedInstance().setCategory(
                    .playback,
                    mode: .default,
                    options: [.mixWithOthers]
                )
            }
        } catch {
            print("Failed to update audio session: \(error)")
        }
    }
} 