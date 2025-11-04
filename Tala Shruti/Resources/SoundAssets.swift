enum SoundAsset: String {
    case C
    case CSharp
    case D
    case DSharp
    case E
    case F
    case FSharp
    case G
    case GSharp
    case A
    case ASharp
    case B
    
    func fileName(mode: ShrutiMode) -> String {
        let noteString: String
        switch self {
        case .CSharp: noteString = "C#"
        case .DSharp: noteString = "D#"
        case .FSharp: noteString = "F#"
        case .GSharp: noteString = "G#"
        case .ASharp: noteString = "A#"
        default: noteString = rawValue
        }
        return "\(noteString)-\(mode.rawValue)"
    }
}

enum ShrutiMode: String, CaseIterable {
    case pa = "pa"
    case ma = "ma"
    case ni = "ni"
    
    var displayName: String {
        switch self {
        case .pa: return "Panchamam (Pa)"
        case .ma: return "Madhyamam (Ma)"
        case .ni: return "Nishadam (Ni)"
        }
    }
    
    var shortName: String {
        switch self {
        case .pa: return "Pa"
        case .ma: return "Ma"
        case .ni: return "Ni"
        }
    }
} 