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
    
    var fileName: String {
        return rawValue
    }
} 