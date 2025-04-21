import Foundation
import AVFoundation

class MetronomeManager: ObservableObject {
    static let shared = MetronomeManager()
    
    @Published var tempo: Double = 60
    @Published var isPlaying = false
    @Published var currentBeat = -1 
    @Published var selectedJati: String = "Chatusra"
    @Published var selectedTalam: String = "Dhruva"
    @Published var isOnBeatsPage = false 
    
    private var timer: Timer?
    private var audioEngine: AVAudioEngine?
    private var audioPlayers: [String: AVAudioPlayerNode] = [:]
    
    private let soundConfigs: [String: (frequency: Float, duration: TimeInterval, volume: Float)] = [
        "high": (1500, 0.12, 0.8),        
        "low": (800, 0.08, 0.6)           
    ]
    
    private let jaatiCounts: [String: Int] = [
        "Tisra": 3,
        "Chatusra": 4,
        "Khanda": 5,
        "Misra": 7,
        "Sankeerna": 9
    ]
    
    private init() {
        setupAudioEngine()
    }
    
    private func setupAudioEngine() {
        guard isOnBeatsPage else { return }
        
        if audioEngine == nil {
            audioEngine = AVAudioEngine()
        }
        
        guard let engine = audioEngine else { return }
        
        do {
            let audioSession = AVAudioSession.sharedInstance()
            if audioSession.isOtherAudioPlaying {
                try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
            }
            try audioSession.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try audioSession.setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
            return
        }
        
        if audioPlayers.isEmpty {
            let mixerNode = AVAudioMixerNode()
            engine.attach(mixerNode)
            engine.connect(mixerNode, to: engine.mainMixerNode, format: nil)
            
            let outputFormat = engine.mainMixerNode.outputFormat(forBus: 0)
            print("Audio engine output format: \(outputFormat)")
            
            for (type, _) in soundConfigs {
                let playerNode = AVAudioPlayerNode()
                engine.attach(playerNode)
                engine.connect(playerNode, to: mixerNode, format: outputFormat)
                audioPlayers[type] = playerNode
            }
        }
        
        if !engine.isRunning {
            do {
                try engine.start()
                print("Metronome audio engine started successfully")
            } catch {
                print("Error starting audio engine: \(error)")
            }
        }
    }
    
    func startMetronome() {
        setupAudioEngine()
        
        isPlaying = true
        currentBeat = -1 
        
        playNextBeat()
        
        let interval = 60.0 / tempo
        
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.playNextBeat()
        }
    }
    
    func stopMetronome() {
        isPlaying = false
        timer?.invalidate()
        timer = nil
        currentBeat = 0
    }
    
    func setTempo(_ newTempo: Double) {
        tempo = newTempo
        if isPlaying {
            stopMetronome()
            startMetronome()
        }
    }
    
    private func playNextBeat() {
        currentBeat = (currentBeat + 1) % getTotalBeats()
        
        let beatType = getCurrentBeatType()
        
        playSound(for: beatType)
    }
    
    private func playSound(for beatType: String) {
        guard audioEngine != nil else { return }
        
        guard let config = soundConfigs[beatType],
              let player = audioPlayers[beatType] else { return }
        
        let buffer = createBuffer(frequency: config.frequency, duration: config.duration)
        
        player.stop()
        
        player.scheduleBuffer(buffer, at: nil, options: .interrupts) {
            DispatchQueue.main.async {
                player.stop()
            }
        }
        
        player.play()
    }
    
    private func createBuffer(frequency: Float, duration: TimeInterval) -> AVAudioPCMBuffer {
        let sampleRate: Float = 44100.0
        let frameCount = AVAudioFrameCount(duration * Double(sampleRate))
        
        guard let format = AVAudioFormat(standardFormatWithSampleRate: Double(sampleRate), channels: 2),
              let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            fatalError("Failed to create buffer")
        }
        
        let leftData = buffer.floatChannelData![0]
        let rightData = buffer.floatChannelData![1]
        
        let twoPi: Float = 2.0 * .pi
        let frequencyRatio = frequency / sampleRate
        
        for frame in 0..<Int(frameCount) {
            let time: Float = Float(frame)
            let phase = twoPi * frequencyRatio * time
            let value = sin(phase)
            
            leftData[frame] = value
            rightData[frame] = value
        }
        
        buffer.frameLength = frameCount
        return buffer
    }
    
    private func getCurrentBeatType() -> String {
        let pattern = getTalamPattern(selectedTalam)
        let totalBeats = getTotalBeats()
        let currentPosition = self.currentBeat % totalBeats
        
        var beatCount = 0
        var currentPatternIndex = 0
        var internalBeatIndex = 0
        
        while currentPatternIndex < pattern.count {
            let beatType = pattern[currentPatternIndex]
            let beatsInType = getBeatsForType(beatType)
            
            if beatCount <= currentPosition && currentPosition < beatCount + beatsInType {
                internalBeatIndex = currentPosition - beatCount
                
                switch beatType {
                case "laghu":
                    return internalBeatIndex == 0 ? "high" : "low"
                case "drutam":
                    return internalBeatIndex % 2 == 0 ? "high" : "low"
                default:
                    return "low"
                }
            }
            
            beatCount += beatsInType
            currentPatternIndex += 1
        }
        
        return "low"
    }
    
    func getBeatTypeForVisual(at absoluteIndex: Int) -> String {
        let pattern = getTalamPattern(selectedTalam)
        let totalBeats = getTotalBeats()
        let position = absoluteIndex % totalBeats
        
        var beatCount = 0
        var currentPatternIndex = 0
        var internalBeatIndex = 0
        
        while currentPatternIndex < pattern.count {
            let beatType = pattern[currentPatternIndex]
            let beatsInType = getBeatsForType(beatType)
            
            if beatCount <= position && position < beatCount + beatsInType {
                internalBeatIndex = position - beatCount
                
                switch beatType {
                case "laghu":
                    if (internalBeatIndex == 0) {
                        return "laghu_start"
                    } else {
                        return "laghu_count"
                    }
                case "drutam":
                    if (internalBeatIndex % 2 == 0) {
                        return "drutam_high"
                    } else {
                        return "drutam_low"
                    }
                case "anudrutam":
                    return "anudrutam"
                default:
                    return "laghu_count"
                }
            }
            
            beatCount += beatsInType
            currentPatternIndex += 1
        }
        
        return "laghu_count" 
    }
    
    func getTotalBeatsCount() -> Int {
        return getTotalBeats()
    }
    
    private func getBeatsForType(_ type: String) -> Int {
        switch type {
        case "sam":
            return 1
        case "laghu":
            return jaatiCounts[selectedJati] ?? 4
        case "drutam":
            return 2
        case "anudrutam":
            return 1
        default:
            return 1
        }
    }
    
    func getTotalBeats() -> Int {
        let pattern = getTalamPattern(selectedTalam)
        var totalBeats = 0
        
        for beatType in pattern {
            totalBeats += getBeatsForType(beatType)
        }
        
        return totalBeats
    }
    
    private func getTalamPattern(_ talam: String) -> [String] {
        switch talam {
        case "Dhruva":
            return ["laghu", "drutam", "laghu", "laghu"]
        case "Matya":
            return ["laghu", "drutam", "laghu"]
        case "Rupaka":
            return ["drutam", "laghu"]
        case "Jhampa":
            return ["laghu", "anudrutam", "drutam"]
        case "Triputa":
            return ["laghu", "drutam", "drutam"]
        case "Ata":
            return ["laghu", "laghu", "drutam", "drutam"]
        case "Eka":
            return ["laghu"]
        default:
            return ["laghu"]
        }
    }
    
    private func getLaghuCount() -> Int {
        return jaatiCounts[selectedJati] ?? 4
    }
    
    func cleanupAudio() {
        guard isOnBeatsPage else { return }
        
        stopMetronome()
        
        if let engine = audioEngine {
            for player in audioPlayers.values {
                player.stop()
            }
            
            if engine.isRunning {
                engine.stop()
            }
            
            for player in audioPlayers.values {
                engine.disconnectNodeOutput(player)
            }
            
            for player in audioPlayers.values {
                engine.detach(player)
            }
            
            do {
                let audioSession = AVAudioSession.sharedInstance()
                try audioSession.setCategory(.ambient, mode: .default)
                try audioSession.setActive(false, options: [.notifyOthersOnDeactivation])
            } catch {
                print("Warning: Could not reset audio session: \(error)")
            }
        }
        
        audioEngine = nil
        audioPlayers.removeAll()
    }
    
    func setBeatsPage(_ isBeatsPage: Bool) {
        isOnBeatsPage = isBeatsPage
        if !isBeatsPage {
            cleanupAudio()
        }
    }
    
    deinit {
        cleanupAudio()
    }
} 
