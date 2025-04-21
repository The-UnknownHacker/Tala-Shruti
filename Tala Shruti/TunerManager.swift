import Foundation
import AVFoundation

class TunerManager: ObservableObject {
    static let shared = TunerManager()
    
    @Published var pitch: Float = 0.0
    @Published var amplitude: Float = 0.0
    @Published var noteNameWithSharps = "-"
    @Published var octave = 0
    @Published var cents: Float = 0.0
    
    private var audioEngine: AVAudioEngine?
    private var inputNode: AVAudioInputNode?
    private var smoothedFrequency: Float = 0.0
    private let smoothingFactor: Float = 0.5  
    
    private let noteFrequencies: [(note: String, frequency: Float)] = [
        ("C", 261.63), ("C♯", 277.18), ("D", 293.66),
        ("D♯", 311.13), ("E", 329.63), ("F", 349.23),
        ("F♯", 369.99), ("G", 392.00), ("G♯", 415.30),
        ("A", 440.00), ("A♯", 466.16), ("B", 493.88)
    ]
    
    init() {
    }
    
    func setupAudioSession() {
    }
    
    private func setupAudioEngine() {
        if let existingEngine = audioEngine, existingEngine.isRunning {
            existingEngine.stop()
            inputNode?.removeTap(onBus: 0)
        }
        
        audioEngine = AVAudioEngine()
        guard let audioEngine = audioEngine else { return }
        
        inputNode = audioEngine.inputNode
        
        guard let inputNode = inputNode else {
            print("Failed to get input node")
            return
        }
        
        let format = inputNode.inputFormat(forBus: 0)
        print("Setting up audio engine with format: \(format)")
        
        if format.sampleRate <= 0 || format.channelCount <= 0 {
            print("Invalid audio format detected, cannot set up engine")
            let validFormat = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 2)
            guard let validFormat = validFormat else {
                print("Couldn't create valid default format")
                return
            }
            
            print("Using default format instead: \(validFormat)")
            
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: validFormat) { [weak self] buffer, time in
                self?.processTunerAudio(buffer: buffer)
            }
        } else {
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, time in
                self?.processTunerAudio(buffer: buffer)
            }
        }
        
        audioEngine.prepare()
    }
    
    private func processTunerAudio(buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let frameLength = UInt(buffer.frameLength)
        
        var sum: Float = 0.0
        for i in stride(from: 0, to: Int(frameLength), by: 4) {
            let sample = channelData[i]
            sum += sample * sample
        }
        let rms = sqrt(sum * 4 / Float(frameLength))
        
        guard rms > 0.01 else {
            DispatchQueue.main.async {
                self.amplitude = rms
                if rms < 0.005 {
                    self.noteNameWithSharps = "-"
                    self.cents = 0
                }
            }
            return
        }
        
        var period = 0
        var bestCorrelation: Float = 0
        let maxShift = min(Int(frameLength/2), 1000)
        let minShift = max(Int(buffer.format.sampleRate/2000), 4)
        
        for shift in stride(from: minShift, through: maxShift, by: 4) {
            var correlation: Float = 0
            for i in stride(from: 0, to: Int(frameLength)-shift, by: 4) {
                correlation += channelData[i] * channelData[i + shift]
            }
            if correlation > bestCorrelation {
                bestCorrelation = correlation
                period = shift
            }
        }
        
        let startPeriod = max(period - 3, minShift)
        let endPeriod = min(period + 3, maxShift)
        for shift in startPeriod...endPeriod {
            var correlation: Float = 0
            for i in 0..<(Int(frameLength)-shift) {
                correlation += channelData[i] * channelData[i + shift]
            }
            if correlation > bestCorrelation {
                bestCorrelation = correlation
                period = shift
            }
        }
        
        let frequency = period > 0 ? Float(buffer.format.sampleRate) / Float(period) : 0
        
        DispatchQueue.main.async {
            self.amplitude = rms
            if frequency > 50 && frequency < 2000 {
                self.smoothedFrequency = self.smoothedFrequency * self.smoothingFactor + 
                                       frequency * (1 - self.smoothingFactor)
                self.updateNoteData(frequency: self.smoothedFrequency)
            }
        }
    }
    
    private func updateNoteData(frequency: Float) {
        let noteNumber = 12 * log2(frequency/440) + 69
        let roundedNoteNumber = round(noteNumber)
        cents = 100 * (noteNumber - roundedNoteNumber)
        
        let noteIndex = Int(roundedNoteNumber) % 12
        octave = Int(roundedNoteNumber) / 12 - 1
        
        if noteIndex >= 0 && noteIndex < noteFrequencies.count {
            noteNameWithSharps = noteFrequencies[noteIndex].note
            pitch = frequency
        }
    }
    
    func start() {
        AudioManager.shared.configureForTunerPage()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.setupAudioEngine()
            
            do {
                guard let audioEngine = self.audioEngine else {
                    print("No audio engine to start")
                    return
                }
                
                try audioEngine.start()
                print("Audio engine started successfully")
            } catch {
                print("Failed to start audio engine: \(error)")
                self.audioEngine?.reset()
                self.audioEngine?.prepare()
                
                do {
                    try self.audioEngine?.start()
                    print("Audio engine started on second attempt")
                } catch {
                    print("Failed to start audio engine on second attempt: \(error)")
                }
            }
        }
    }
    
    func startWithoutConfiguring() {
        if let existingEngine = audioEngine, existingEngine.isRunning {
            existingEngine.stop()
            inputNode?.removeTap(onBus: 0)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.setupAudioEngine()
            
            do {
                guard let audioEngine = self.audioEngine else {
                    print("No audio engine to start")
                    return
                }
                
                try audioEngine.start()
                print("Audio engine started successfully")
            } catch {
                print("Failed to start audio engine: \(error)")
            }
        }
    }
    
    func stop() {
        guard let audioEngine = audioEngine else { return }
        
        audioEngine.stop()
        inputNode?.removeTap(onBus: 0)
        self.audioEngine = nil
        self.inputNode = nil
        
        print("Audio engine stopped")
    }
} 
