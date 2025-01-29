import Foundation
import AVFoundation

class AudioManager: ObservableObject {
    static let shared = AudioManager()
    private let gainBoost: Float = 5.0 // Adjust this value to control the amount of gain boost
    
    private init() {
        setupAudioSession()
    }
    
    func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
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
    
    func createPlayer(for asset: SoundAsset) -> AVAudioPlayer? {
        guard let path = Bundle.main.path(forResource: asset.fileName, ofType: "wav") else {
            print("Failed to find sound file: \(asset.fileName)")
            return nil
        }
        
        do {
            let player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            player.enableRate = true
            player.prepareToPlay()
            player.volume = gainBoost // Apply gain boost
            return player
        } catch {
            print("Failed to create audio player: \(error)")
            return nil
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
                    mode: .default
                )
            }
        } catch {
            print("Failed to update audio session: \(error)")
        }
    }
} 