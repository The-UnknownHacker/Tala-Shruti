import Foundation
import SwiftUI

struct Lyrics: Identifiable, Codable, Equatable {
    var id: String
    var title: String
    var content: String
    var createdAt: Date
    var userId: String
    var color: String 
    
    init(id: String = UUID().uuidString, 
         title: String, 
         content: String, 
         createdAt: Date = Date(), 
         userId: String,
         color: String = "blue") {
        self.id = id
        self.title = title
        self.content = content
        self.createdAt = createdAt
        self.userId = userId
        self.color = color
    }
    
    var displayColor: Color {
        switch color {
        case "red": return .red
        case "green": return .green
        case "blue": return .blue
        case "purple": return .purple
        case "orange": return .orange
        case "yellow": return .yellow
        default: return .blue
        }
    }
    
    static func == (lhs: Lyrics, rhs: Lyrics) -> Bool {
        lhs.id == rhs.id
    }
    
    static let example = Lyrics(
        title: "Sample Lyrics",
        content: "These are some sample lyrics\nThat span multiple lines\nFor testing purposes",
        userId: "preview_user"
    )
} 