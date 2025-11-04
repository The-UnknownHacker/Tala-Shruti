
import Foundation
import AVFoundation
import Combine

class RagaTrainingManager: ObservableObject {
    @Published var currentNoteIndex: Int = 0
    @Published var completedNotes: Set<Int> = []
    @Published var detectedFrequency: Float = 0.0
    @Published var isListening: Bool = false
    @Published var selectedRaga: Raga = .mayamalavagowla
    @Published var selectedShruti: SoundAsset = .C
    @Published var amplitude: Float = 0.0
    @Published var baseRaga: Raga = .mayamalavagowla
    
    private var audioEngine: AVAudioEngine?
    private var inputNode: AVAudioInputNode?
    private var smoothedFrequency: Float = 0.0
    private let smoothingFactor: Float = 0.5
    private var matchCounter: Int = 0
    private let matchThreshold: Int = 8
    
    var currentNote: RagaNote? {
        guard currentNoteIndex < selectedRaga.notes.count else { return nil }
        return selectedRaga.notes[currentNoteIndex]
    }
    
    var isComplete: Bool {
        currentNoteIndex >= selectedRaga.notes.count
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
                self.isListening = true
                print("Raga training audio engine started")
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
        self.isListening = false
        
        print("Raga training audio engine stopped")
    }
    
    func reset() {
        currentNoteIndex = 0
        completedNotes.removeAll()
        matchCounter = 0
    }
    
    func updateRaga(_ raga: Raga) {
        baseRaga = raga
        adjustRagaToShruti()
        reset()
    }
    
    func updateShruti(_ shruti: SoundAsset) {
        selectedShruti = shruti
        adjustRagaToShruti()
    }
    
    private func adjustRagaToShruti() {
        let baseFrequency = getFrequencyForShruti(selectedShruti)
        let ratio = baseFrequency / 130.0  
        
        let adjustedNotes = baseRaga.notes.map { note in
            RagaNote(swaraName: note.swaraName, frequency: note.frequency * ratio)
        }
        
        selectedRaga = Raga(name: baseRaga.name, notes: adjustedNotes)
        print("RagaTraining: Adjusted \(baseRaga.name) to \(selectedShruti.displayName) with ratio \(ratio)")
    }
    
    private func getFrequencyForShruti(_ shruti: SoundAsset) -> Float {
        switch shruti {
        case .C: return 130.0      
        case .CSharp: return 138.0 
        case .D: return 147.0      
        case .DSharp: return 156.0 
        case .E: return 165.0      
        case .F: return 175.0      
        case .FSharp: return 185.0 
        case .G: return 196.0      
        case .GSharp: return 208.0 
        case .A: return 220.0     
        case .ASharp: return 233.0 
        case .B: return 247.0      
        }
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
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, time in
            self?.processAudio(buffer: buffer)
        }
        
        audioEngine.prepare()
    }
    
    private func processAudio(buffer: AVAudioPCMBuffer) {
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
                self.detectedFrequency = self.smoothedFrequency
                self.checkNoteMatch()
            }
        }
    }
    
    private func checkNoteMatch() {
        guard currentNoteIndex < selectedRaga.notes.count else { 
            print("RagaTraining: Already at end of notes")
            return 
        }
        let currentNote = selectedRaga.notes[currentNoteIndex]
        
        if currentNote.matches(detectedFrequency: detectedFrequency) {
            matchCounter += 1
            
            if matchCounter >= matchThreshold {
                print("RagaTraining: Matched note \(currentNote.swaraName) at index \(currentNoteIndex)")
                completedNotes.insert(currentNoteIndex)
                matchCounter = 0
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    if self.currentNoteIndex < self.selectedRaga.notes.count - 1 {
                        self.currentNoteIndex += 1
                        print("RagaTraining: Advanced to note index \(self.currentNoteIndex)")
                    } else {
                        print("RagaTraining: Completed all notes!")
                    }
                }
            }
        } else {
            matchCounter = max(0, matchCounter - 1)
        }
    }
}
