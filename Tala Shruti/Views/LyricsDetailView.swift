import SwiftUI

struct LyricsDetailView: View {
    let lyrics: Lyrics
    @ObservedObject private var lyricsManager = LyricsManager.shared
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
    
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
        ZStack {
            backgroundColor
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: horizontalSizeClass == .regular ? 30 : 20) {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(lyrics.title)
                                .font(horizontalSizeClass == .regular ? .system(size: 36, weight: .bold) : .largeTitle)
                                .fontWeight(.bold)
                            
                            Text("Created \(dateFormatter.string(from: lyrics.createdAt))")
                                .font(horizontalSizeClass == .regular ? .subheadline : .caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(horizontalSizeClass == .regular ? 24 : 16)
                    .background(lyrics.displayColor.opacity(0.2))
                    .cornerRadius(12)
                    
                    Text(lyrics.content)
                        .font(horizontalSizeClass == .regular ? .title3 : .body)
                        .padding(horizontalSizeClass == .regular ? 24 : 16)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                }
                .padding(horizontalSizeClass == .regular ? 24 : 16)
                .frame(maxWidth: horizontalSizeClass == .regular ? 800 : nil)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {
                        showingEditSheet = true
                    }) {
                        Label("Edit", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive, action: {
                        showingDeleteAlert = true
                    }) {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            LyricsEditorView(mode: .edit(lyrics))
        }
        .alert("Delete Lyrics", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                lyricsManager.deleteLyrics(id: lyrics.id)
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete this lyrics? This action cannot be undone.")
        }
    }
}

struct LyricsDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LyricsDetailView(lyrics: Lyrics.example)
        }
    }
} 