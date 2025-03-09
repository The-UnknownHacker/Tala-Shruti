import Foundation
import AVFoundation

enum AudioSessionMode {
    case mainPage       // Main page: Speaker output only
    case tunerPage      // Tuner page: Microphone input only
}

class AudioManager: ObservableObject {
    static let shared = AudioManager()
    private let gainBoost: Float = 5.0 // Adjust this value to control the amount of gain boost
    @Published var currentMode: AudioSessionMode = .mainPage
    
    private init() {
        // Don't automatically configure - wait for explicit calls
    }
    
    func configureForMainPage() {
        do {
            // First deactivate any existing session
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            
            // Now configure for playback
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
            
            // Finally update state
            currentMode = .mainPage
            print("Successfully configured audio for main page")
        } catch {
            print("Failed to configure audio for main page: \(error)")
        }
    }
    
    func configureForTunerPage() {
        do {
            // First deactivate any existing session
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            
            // Now configure for tuner
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .measurement)
            try session.setPreferredIOBufferDuration(0.005)
            try session.setActive(true)
            
            // Finally update state
            currentMode = .tunerPage
            print("Successfully configured audio for tuner page")
        } catch {
            print("Failed to configure audio for tuner page: \(error)")
        }
    }
    
    func createPlayer(for asset: SoundAsset) -> AVAudioPlayer? {
        // Make sure we're in the right mode for playback
        if currentMode != .mainPage {
            configureForMainPage()
        }
        
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
        // Only apply to main page mode
        if currentMode != .mainPage {
            return
        }
        
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            
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
            
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to update audio session: \(error)")
        }
    }
} 