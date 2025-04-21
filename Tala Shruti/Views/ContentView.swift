import SwiftUI

struct ContentView: View {
    @Environment(\.scenePhase) var scenePhase
    
    var body: some View {
        TabView {
            ShrutiBoxView()
                .tabItem {
                    Label("Shruti", systemImage: "music.note")
                }
            
            LyricsListView()
                .tabItem {
                    Label("Lyrics", systemImage: "doc.text")
                }
        }
        .onChange(of: scenePhase) { phase in
            if phase == .background {
                NotificationCenter.default.post(name: .savePreferences, object: nil)
            }
        }
        .onAppear {
            let appearance = UITabBarAppearance()
            appearance.configureWithDefaultBackground()
            UITabBar.appearance().scrollEdgeAppearance = appearance
            UITabBar.appearance().standardAppearance = appearance
            
            AudioManager.shared.configureForMainPage()
        }
    }
}

#Preview {
    ContentView()
} 