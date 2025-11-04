import Foundation
import AVFoundation

enum AudioSessionMode {
    case mainPage       
    case tunerPage      
}

class AudioManager: ObservableObject {
    static let shared = AudioManager()
    private let gainBoost: Float = 5.0
    @Published var currentMode: AudioSessionMode = .mainPage
    
    private init() {
    }
    
    func configureForMainPage() {
        do {
            if currentMode == .tunerPage {
                try AVAudioSession.sharedInstance().setActive(false, options: [.notifyOthersOnDeactivation])
                Thread.sleep(forTimeInterval: 0.1)
            }
            
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            
            var success = false
            for _ in 1...3 {
                do {
                    try session.setActive(true)
                    success = true
                    break
                } catch {
                    Thread.sleep(forTimeInterval: 0.1)
                }
            }
            
            if !success {
                print("Warning: Failed multiple attempts to activate audio session for main page")
                try? session.setActive(true)
            }
            
            currentMode = .mainPage
            print("Successfully configured audio for main page")
        } catch {
            print("Failed to configure audio for main page: \(error)")
        }
    }
    
    func configureForTunerPage() {
        do {
            if currentMode == .mainPage {
                try? AVAudioSession.sharedInstance().setActive(false, options: [])
                Thread.sleep(forTimeInterval: 0.1)
            }
            
            let session = AVAudioSession.sharedInstance()
            
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
            try session.setPreferredIOBufferDuration(0.005)
            
            var success = false
            for _ in 1...3 {
                do {
                    try session.setActive(true)
                    success = true
                    break
                } catch {
                    Thread.sleep(forTimeInterval: 0.1)
                }
            }
            
            if !success {
                print("Warning: Failed multiple attempts to activate audio session for tuner page")
                try? session.setActive(true)
            }
            
            currentMode = .tunerPage
            print("Successfully configured audio for tuner page")
        } catch {
            print("Failed to configure audio for tuner page: \(error)")
        }
    }
    
    func createPlayer(for asset: SoundAsset, mode: ShrutiMode) -> AVAudioPlayer? {
        if currentMode != .mainPage {
            configureForMainPage()
        }
        
        let fileName = asset.fileName(mode: mode)
        guard let path = Bundle.main.path(forResource: fileName, ofType: "wav") else {
            print("Failed to find sound file: \(fileName)")
            return nil
        }
        
        do {
            let player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            player.enableRate = true
            player.prepareToPlay()
            player.volume = gainBoost 
            return player
        } catch {
            print("Failed to create audio player: \(error)")
            return nil
        }
    }
    
    func enableBackgroundPlayback(_ enabled: Bool) {
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