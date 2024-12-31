import Foundation

struct TalamPreset: Identifiable, Codable {
    let id: UUID
    let name: String
    let beats: Int
    let accentPattern: [Bool]
    let description: String
    let isCustom: Bool
    var isFavorite: Bool
    
    init(id: UUID = UUID(), name: String, beats: Int, accentPattern: [Bool], description: String, isCustom: Bool = false, isFavorite: Bool = false) {
        self.id = id
        self.name = name
        self.beats = beats
        self.accentPattern = accentPattern
        self.description = description
        self.isCustom = isCustom
        self.isFavorite = isFavorite
    }
    
    static let defaultPresets = [
        TalamPreset(
            name: "Adi Talam",
            beats: 8,
            accentPattern: [true, false, false, false, true, false, true, false],
            description: "8 beats",
            isCustom: false,
            isFavorite: false
        ),
        TalamPreset(
            name: "Rupaka",
            beats: 3,
            accentPattern: [true, false, false],
            description: "3 beats",
            isCustom: false,
            isFavorite: false
        ),
        TalamPreset(
            name: "Eka Talam",
            beats: 4,
            accentPattern: [true, false, false, false],
            description: "4 beats",
            isCustom: false,
            isFavorite: false
        )
    ]
} 
