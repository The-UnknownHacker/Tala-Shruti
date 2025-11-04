import Foundation

protocol RagaDefinition {
    var name: String { get }
    var notes: [RagaNote] { get }
}

struct Raga: Identifiable {
    let id = UUID()
    let name: String
    let notes: [RagaNote]
    
    init(name: String, notes: [RagaNote]) {
        self.name = name
        self.notes = notes
    }
    
    init(from definition: RagaDefinition) {
        self.name = definition.name
        self.notes = definition.notes
    }
    
    static var allRagas: [Raga] {
        return RagaRegistry.shared.allRagas
    }
}

class RagaRegistry {
    static let shared = RagaRegistry()
    
    private(set) var allRagas: [Raga] = []
    
    private init() {
        registerRagas()
    }
    
    private func registerRagas() {
        allRagas = [
            Raga(from: MayamalavagowlaRaga()),
            Raga(from: HindolamRaga())
        ]
    }
}

struct RagaNote: Identifiable {
    let id = UUID()
    let swaraName: String
    let frequency: Float
    
    func matches(detectedFrequency: Float, tolerance: Float = 4.0) -> Bool {
        guard detectedFrequency > 0 else { return false }
        
        let ratio = detectedFrequency / frequency
        let octaveAdjustedFreq: Float
        
        if ratio > 1.9 {
            octaveAdjustedFreq = detectedFrequency / 4
        } else if ratio > 1.5 {
            octaveAdjustedFreq = detectedFrequency / 2
        } else if ratio < 0.55 {
            octaveAdjustedFreq = detectedFrequency * 2
        } else if ratio < 0.28 {
            octaveAdjustedFreq = detectedFrequency * 4
        } else {
            octaveAdjustedFreq = detectedFrequency
        }
        
        let difference = abs(octaveAdjustedFreq - frequency)
        let isMatch = difference < tolerance
        
        if isMatch {
            print("RagaNote: \(swaraName) matched! Target: \(frequency)Hz, Detected: \(detectedFrequency)Hz, Adjusted: \(octaveAdjustedFreq)Hz, Diff: \(difference)Hz")
        }
        
        return isMatch
    }
}
