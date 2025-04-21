import SwiftUI
import AuthenticationServices

struct AuthenticationView: View {
    @ObservedObject private var authManager = AuthManager.shared
    @Environment(\.colorScheme) var colorScheme
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
            
            VStack(spacing: 30) {
                Spacer()
                
                VStack(spacing: 20) {
                    Image(systemName: "music.note.list")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .foregroundColor(.blue)
                    
                    Text("Tala Shruti")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                    
                    Text("Sign in to access your lyrics")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(spacing: 20) {
                    if !authManager.isAuthenticated {
                        SignInWithAppleButton()
                            .frame(height: 50)
                            .cornerRadius(8)
                            .padding(.horizontal, 40)
                        
                        Text("Your lyrics will be saved to your account")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        VStack(spacing: 15) {
                            Text("Welcome back")
                                .font(.headline)
                            
                            if !authManager.userName.isEmpty {
                                Text(authManager.userName)
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }
                            
                            Button(action: {
                                dismiss()
                            }) {
                                Text("Continue to Lyrics")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(height: 50)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.blue)
                                    .cornerRadius(8)
                            }
                            .padding(.horizontal, 40)
                            .padding(.top, 10)
                            
                            Button(action: {
                                authManager.signOut()
                            }) {
                                Text("Sign Out")
                                    .foregroundColor(.red)
                            }
                            .padding(.top, 20)
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    AuthenticationView()
} 