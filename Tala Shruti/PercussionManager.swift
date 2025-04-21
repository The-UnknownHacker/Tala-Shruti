import Foundation
import AVFoundation

class PercussionManager: ObservableObject {
    static let shared = PercussionManager()
    
    @Published var tempo: Double = 100.0
    @Published var selectedInstrument = "Tabla"
    @Published private(set) var activeButton: Int?
    @Published var isOnPercussionPage = false
    
    private var players: [AVAudioPlayer] = []
    
    private let tablaFiles = ["Tabla1", "Tabla2", "Tabla3", "Tabla4"]
    private let mridangamFiles = ["Mrid1", "Mrid2", "Mrid3", "Mrid4"]
    
    init() {
        setupAudioPlayers()
    }
    
    private func setupAudioPlayers() {
        let files = selectedInstrument == "Tabla" ? tablaFiles : mridangamFiles
        players = files.compactMap { filename in
            guard let path = Bundle.main.path(forResource: filename, ofType: "wav") else { return nil }
            let player = try? AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            player?.numberOfLoops = -1  
            player?.prepareToPlay()
            player?.enableRate = true  
            return player
        }
    }
    
    func toggleInstrument() {
        stopPlaying()
        selectedInstrument = selectedInstrument == "Tabla" ? "Mridangam" : "Tabla"
        setupAudioPlayers()
    }
    
    func toggleSound(_ index: Int) {
        if activeButton == index {
            stopPlaying()
        } else {
            startPlaying(index)
        }
    }
    
    private func startPlaying(_ index: Int) {
        stopPlaying()
        guard index < players.count else { return }
        
        activeButton = index
        let player = players[index]
        player.rate = Float(tempo / 100.0)  
        player.play()
    }
    
    func stopPlaying() {
        players.forEach { $0.stop() }
        activeButton = nil
    }
    
    func setTempo(_ newTempo: Double) {
        tempo = max(30, min(300, newTempo))
        if let currentButton = activeButton {
            players[currentButton].rate = Float(tempo / 100.0)
        }
    }
    
    func cleanupAudio() {
        stopPlaying()
        players.removeAll()
    }
} 