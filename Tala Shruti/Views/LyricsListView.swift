import SwiftUI

struct LyricsListView: View {
    @ObservedObject private var lyricsManager = LyricsManager.shared
    @ObservedObject private var authManager = AuthManager.shared
    @State private var showingAddSheet = false
    @State private var showingAuthSheet = false
    @State private var showingDetail = false
    @State private var selectedLyrics: Lyrics?
    @State private var isRefreshing = false
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    private var columns: [GridItem] {
        if horizontalSizeClass == .regular {
            return [
                GridItem(.adaptive(minimum: 250, maximum: 300), spacing: 20)
            ]
        } else {
            return [
                GridItem(.adaptive(minimum: 160, maximum: 200), spacing: 16)
            ]
        }
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
        NavigationView {
            ZStack {
                backgroundColor
                    .ignoresSafeArea()
                
                if !authManager.isAuthenticated {
                    VStack(spacing: 20) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        
                        Text("Sign in to View Your Lyrics")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Your lyrics will be saved to your account")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button(action: {
                            showingAuthSheet = true
                        }) {
                            Text("Sign In")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(height: 50)
                                .frame(width: 200)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        .padding(.top, 20)
                    }
                    .padding()
                    .frame(maxWidth: horizontalSizeClass == .regular ? 500 : nil)
                } else if lyricsManager.userLyrics.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        
                        Text("No Lyrics Found")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Tap the + button to add your first lyrics")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button(action: {
                            refreshLyrics()
                        }) {
                            Label("Refresh", systemImage: "arrow.clockwise")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(height: 40)
                                .frame(width: 150)
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                        .padding(.top, 10)
                    }
                    .padding()
                    .frame(maxWidth: horizontalSizeClass == .regular ? 500 : nil)
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: horizontalSizeClass == .regular ? 20 : 16) {
                            ForEach(lyricsManager.userLyrics) { lyrics in
                                LyricsCard(lyrics: lyrics, isIPad: horizontalSizeClass == .regular)
                                    .onTapGesture {
                                        selectedLyrics = lyrics
                                        showingDetail = true
                                    }
                            }
                        }
                        .padding(horizontalSizeClass == .regular ? 24 : 16)
                        .frame(maxWidth: .infinity)
                    }
                    .frame(maxWidth: .infinity)
                    .refreshable {
                        refreshLyrics()
                    }
                }
            }
            .navigationTitle("Lyrics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if authManager.isAuthenticated {
                        Menu {
                            Button(action: {
                                authManager.signOut()
                                lyricsManager.loadLyrics()
                            }) {
                                Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                            }
                        } label: {
                            Label("Account", systemImage: "person.circle")
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if authManager.isAuthenticated {
                        HStack {
                            Button(action: {
                                refreshLyrics()
                            }) {
                                Image(systemName: "arrow.clockwise")
                            }
                            .disabled(isRefreshing)
                            
                            Button(action: {
                                showingAddSheet = true
                            }) {
                                Image(systemName: "plus")
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                LyricsEditorView(mode: .add)
            }
            .sheet(isPresented: $showingAuthSheet) {
                AuthenticationView()
            }
            .sheet(isPresented: $showingDetail) {
                if let lyrics = selectedLyrics {
                    LyricsDetailView(lyrics: lyrics)
                }
            }
            .onAppear {
                print("LyricsListView: View appeared - isAuthenticated: \(authManager.isAuthenticated)")
                if authManager.isAuthenticated {
                    refreshLyrics()
                }
                
                if !authManager.isAuthenticated {
                    showingAuthSheet = true
                }
            }
            .onChange(of: authManager.isAuthenticated) { isAuthenticated in
                print("LyricsListView: Authentication state changed - isAuthenticated: \(isAuthenticated)")
                if isAuthenticated {
                    refreshLyrics()
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func refreshLyrics() {
        print("LyricsListView: Refreshing lyrics")
        isRefreshing = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            lyricsManager.refreshLyrics()
            isRefreshing = false
        }
    }
}

struct LyricsCard: View {
    let lyrics: Lyrics
    let isIPad: Bool
    @ObservedObject private var lyricsManager = LyricsManager.shared
    @State private var showingDeleteAlert = false
    @State private var showingEditSheet = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(lyrics.title)
                .font(isIPad ? .title3 : .headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(isIPad ? 16 : 12)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            Text(lyrics.content)
                .font(isIPad ? .body : .caption)
                .foregroundColor(.white.opacity(0.9))
                .padding(isIPad ? 16 : 12)
                .lineLimit(isIPad ? 8 : 3)
                .frame(maxWidth: .infinity, minHeight: isIPad ? 120 : 80, alignment: .topLeading)
        }
        .frame(height: isIPad ? 200 : 160)
        .frame(maxWidth: .infinity)
        .background(lyrics.displayColor)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 2)
        .contextMenu {
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
        }
        .sheet(isPresented: $showingEditSheet) {
            LyricsEditorView(mode: .edit(lyrics))
        }
        .alert("Delete Lyrics", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                lyricsManager.deleteLyrics(id: lyrics.id)
            }
        } message: {
            Text("Are you sure you want to delete this lyrics? This action cannot be undone.")
        }
    }
}

#Preview {
    LyricsListView()
} 