import SwiftUI

enum LyricsEditorMode {
    case add
    case edit(Lyrics)
}

struct LyricsEditorView: View {
    let mode: LyricsEditorMode
    
    @ObservedObject private var lyricsManager = LyricsManager.shared
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @State private var title = ""
    @State private var content = ""
    @State private var selectedColor = "blue"
    @State private var lyricsId = ""
    
    private let colorOptions = [
        "blue", "purple", "green", "orange", "red", "yellow"
    ]
    
    private var backgroundColor: LinearGradient {
        let isDark = colorScheme == .dark
        return LinearGradient(
            gradient: Gradient(colors: [
                isDark ? Color(white: 0.2) : Color(.systemGray6),
                isDark ? Color(white: 0.1) : Color(.systemBackground)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundColor
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: horizontalSizeClass == .regular ? 30 : 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Title")
                                .font(horizontalSizeClass == .regular ? .title2 : .headline)
                                .foregroundColor(.secondary)
                            
                            TextField("Enter a title", text: $title)
                                .padding(horizontalSizeClass == .regular ? 16 : 12)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                                .font(horizontalSizeClass == .regular ? .title3 : .headline)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Lyrics")
                                .font(horizontalSizeClass == .regular ? .title2 : .headline)
                                .foregroundColor(.secondary)
                            
                            TextEditor(text: $content)
                                .padding(horizontalSizeClass == .regular ? 16 : 12)
                                .frame(minHeight: horizontalSizeClass == .regular ? 400 : 200)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                                .font(horizontalSizeClass == .regular ? .title3 : .body)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Color")
                                .font(horizontalSizeClass == .regular ? .title2 : .headline)
                                .foregroundColor(.secondary)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: horizontalSizeClass == .regular ? 16 : 12) {
                                    ForEach(colorOptions, id: \.self) { color in
                                        ColorOption(
                                            color: color,
                                            isSelected: selectedColor == color,
                                            action: { selectedColor = color }
                                        )
                                        .frame(width: horizontalSizeClass == .regular ? 60 : 44,
                                               height: horizontalSizeClass == .regular ? 60 : 44)
                                    }
                                }
                                .padding(.horizontal, 4)
                            }
                        }
                    }
                    .padding(horizontalSizeClass == .regular ? 24 : 16)
                    .frame(maxWidth: horizontalSizeClass == .regular ? 800 : nil)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(isEditing ? "Edit Lyrics" : "New Lyrics")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(horizontalSizeClass == .regular ? .title3 : .body)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? "Save" : "Add") {
                        if isEditing {
                            lyricsManager.updateLyrics(
                                id: lyricsId,
                                title: title,
                                content: content,
                                color: selectedColor
                            )
                        } else {
                            lyricsManager.addLyrics(
                                title: title,
                                content: content,
                                color: selectedColor
                            )
                        }
                        dismiss()
                    }
                    .font(horizontalSizeClass == .regular ? .title3 : .body)
                    .disabled(title.isEmpty || content.isEmpty)
                }
            }
            .onAppear {
                if case .edit(let lyrics) = mode {
                    title = lyrics.title
                    content = lyrics.content
                    selectedColor = lyrics.color
                    lyricsId = lyrics.id
                }
            }
        }
    }
    
    private var isEditing: Bool {
        if case .edit = mode {
            return true
        }
        return false
    }
}

struct ColorOption: View {
    let color: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Circle()
                .fill(Color(color))
                .overlay(
                    Circle()
                        .strokeBorder(isSelected ? Color.white : Color.clear, lineWidth: 2)
                )
                .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
        }
    }
}

#Preview {
    LyricsEditorView(mode: .add)
} 