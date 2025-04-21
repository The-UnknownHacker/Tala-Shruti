import SwiftUI
import AuthenticationServices

struct LandingView: View {
    @ObservedObject private var authManager = AuthManager.shared
    @Environment(\.colorScheme) var colorScheme
    @State private var currentPage = 0
    @AppStorage("hasSeenLanding") private var hasSeenLanding = false
    @Environment(\.dismiss) private var dismiss
    
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
            
            TabView(selection: $currentPage) {
                VStack(spacing: 30) {
                    Spacer()
                    
                    Image(systemName: "music.note.list")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .foregroundColor(.blue)
                    
                    Text("Welcome to Tala Shruti")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                    
                    Text("Your Digital Indian Classical Music Companion")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Spacer()
                    
                    Button(action: { currentPage = 1 }) {
                        Text("Get Started")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(height: 50)
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 50)
                }
                .tag(0)
                
                VStack(spacing: 30) {
                    Spacer()
                    
                    Text("Discover Tala Shruti")
                        .font(.title.bold())
                    
                    VStack(spacing: 25) {
                        LandingFeatureRow(icon: "music.note", title: "Shruti Box", description: "Play precise shrutis with adjustable volume")
                        LandingFeatureRow(icon: "metronome", title: "Metronome", description: "Practice with custom patterns and tempo")
                        LandingFeatureRow(icon: "music.mic", title: "Percussion", description: "Access Tabla and Mridangam loops")
                        LandingFeatureRow(icon: "waveform", title: "Tuner", description: "Fine-tune your instrument with precision")
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    Button(action: { currentPage = 2 }) {
                        Text("Continue")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(height: 50)
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 50)
                }
                .tag(1)
                
                VStack(spacing: 30) {
                    Spacer()
                    
                    Text("Sign In to Get Started")
                        .font(.title2.bold())
                    
                    Text("Create an account to save your preferences and access your lyrics")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Spacer()
                    
                    VStack(spacing: 20) {
                        SignInWithAppleButton()
                            .frame(height: 50)
                            .cornerRadius(8)
                            .padding(.horizontal, 40)
                        
                        Text("Your data is securely stored in your account")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .tag(2)
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
        }
        .onChange(of: authManager.isAuthenticated) { isAuthenticated in
            print("LandingView: Authentication state changed - isAuthenticated: \(isAuthenticated)")
            if isAuthenticated {
                print("LandingView: User is authenticated, setting hasSeenLanding to true")
                hasSeenLanding = true
                print("LandingView: Dismissing view")
                dismiss()
            }
        }
        .onAppear {
            print("LandingView: View appeared - isAuthenticated: \(authManager.isAuthenticated)")
            if authManager.isAuthenticated {
                print("LandingView: User is already authenticated, setting hasSeenLanding to true")
                hasSeenLanding = true
                print("LandingView: Dismissing view")
                dismiss()
            }
        }
    }
}

struct LandingFeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 20) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

#Preview {
    LandingView()
} 