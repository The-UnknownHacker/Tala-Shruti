import Foundation
import AVFoundation

class MetronomeManager: ObservableObject {
    static let shared = MetronomeManager()
    
    @Published var isPlaying = false
    @Published var tempo: Double = 120.0
    @Published var currentBeat = 0
    @Published var selectedPreset: TalamPreset?
    @Published var presets: [TalamPreset]
    
    private var timer: Timer?
    private var accentedBeatSound: AVAudioPlayer?
    private var normalBeatSound: AVAudioPlayer?
    
    init() {
        // Load saved presets or use defaults
        if let savedPresets = UserDefaults.standard.data(forKey: "savedPresets"),
           let decoded = try? JSONDecoder().decode([TalamPreset].self, from: savedPresets) {
            self.presets = TalamPreset.defaultPresets + decoded
        } else {
            self.presets = TalamPreset.defaultPresets
        }
        
        setupAudioPlayers()
        selectedPreset = presets[0]
    }
    
    func addCustomPreset(_ preset: TalamPreset) {
        let customPreset = TalamPreset(
            name: preset.name,
            beats: preset.beats,
            accentPattern: preset.accentPattern,
            description: preset.description,
            isCustom: true
        )
        presets.append(customPreset)
        savePresets()
    }
    
    func toggleFavorite(_ preset: TalamPreset) {
        if let index = presets.firstIndex(where: { $0.id == preset.id }) {
            presets[index].isFavorite.toggle()
            savePresets()
        }
    }
    
    func deletePreset(_ preset: TalamPreset) {
        if preset.isCustom {
            presets.removeAll(where: { $0.id == preset.id })
            savePresets()
        }
    }
    
    private func savePresets() {
        let customPresets = presets.filter { $0.isCustom }
        if let encoded = try? JSONEncoder().encode(customPresets) {
            UserDefaults.standard.set(encoded, forKey: "savedPresets")
        }
    }
    
    private func setupAudioPlayers() {
        if let accentedPath = Bundle.main.path(forResource: "Hi", ofType: "wav") {
            accentedBeatSound = try? AVAudioPlayer(contentsOf: URL(fileURLWithPath: accentedPath))
            accentedBeatSound?.prepareToPlay()
        }
        
        if let normalPath = Bundle.main.path(forResource: "Low", ofType: "wav") {
            normalBeatSound = try? AVAudioPlayer(contentsOf: URL(fileURLWithPath: normalPath))
            normalBeatSound?.prepareToPlay()
        }
    }
    
    func startMetronome() {
        guard let preset = selectedPreset else { return }
        
        isPlaying = true
        currentBeat = 0
        
        let interval = 60.0 / tempo
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.playBeat()
        }
    }
    
    func stopMetronome() {
        isPlaying = false
        timer?.invalidate()
        timer = nil
        currentBeat = 0
    }
    
    private func playBeat() {
        guard let preset = selectedPreset else { return }
        
        if preset.accentPattern[currentBeat] {
            accentedBeatSound?.play()
        } else {
            normalBeatSound?.play()
        }
        
        currentBeat = (currentBeat + 1) % preset.beats
    }
    
    func setTempo(_ newTempo: Double) {
        tempo = max(30, min(300, newTempo))
        if isPlaying {
            stopMetronome()
            startMetronome()
        }
    }
} 