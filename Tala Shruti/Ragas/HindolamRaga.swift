import Foundation

struct HindolamRaga: RagaDefinition {
    let name = "Hindolam"
    
    let notes: [RagaNote] = [
        RagaNote(swaraName: "S", frequency: 130.0),    
        RagaNote(swaraName: "G2", frequency: 156.0),   
        RagaNote(swaraName: "M1", frequency: 175.0),   
        RagaNote(swaraName: "D1", frequency: 210.0),   
        RagaNote(swaraName: "N2", frequency: 235.0),   
        RagaNote(swaraName: "S", frequency: 260.0)     
    ]
}
