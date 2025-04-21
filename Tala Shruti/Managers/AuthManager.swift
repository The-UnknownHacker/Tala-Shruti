import Foundation
import AuthenticationServices
import SwiftUI

class AuthManager: NSObject, ObservableObject {
    static let shared = AuthManager()
    
    @Published var isAuthenticated = false
    @Published var userId: String = ""
    @Published var userName: String = ""
    @Published var userEmail: String = ""
    
    private override init() {
        super.init()
        checkAuthenticationState()
    }
    
    private func checkAuthenticationState() {
        if let userId = UserDefaults.standard.string(forKey: "auth_user_id"),
           !userId.isEmpty {
            self.userId = userId
            self.userName = UserDefaults.standard.string(forKey: "auth_user_name") ?? ""
            self.userEmail = UserDefaults.standard.string(forKey: "auth_user_email") ?? ""
            self.isAuthenticated = true
            print("AuthManager: Restored authentication state - isAuthenticated: \(isAuthenticated)")
        }
    }
    
    func signOut() {
        UserDefaults.standard.removeObject(forKey: "auth_user_id")
        UserDefaults.standard.removeObject(forKey: "auth_user_name")
        UserDefaults.standard.removeObject(forKey: "auth_user_email")
        
        self.userId = ""
        self.userName = ""
        self.userEmail = ""
        self.isAuthenticated = false
        print("AuthManager: Signed out - isAuthenticated: \(isAuthenticated)")
    }
    
    func saveUserData(userId: String, name: String?, email: String?) {
        self.userId = userId
        self.userName = name ?? ""
        self.userEmail = email ?? ""
        self.isAuthenticated = true
        
        UserDefaults.standard.set(userId, forKey: "auth_user_id")
        if let name = name {
            UserDefaults.standard.set(name, forKey: "auth_user_name")
        }
        if let email = email {
            UserDefaults.standard.set(email, forKey: "auth_user_email")
        }
        print("AuthManager: Saved user data - isAuthenticated: \(isAuthenticated), userId: \(userId)")
    }
}

extension AuthManager: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let userId = appleIDCredential.user
            let name = appleIDCredential.fullName?.givenName
            let email = appleIDCredential.email
            
            print("AuthManager: Received Apple ID credential - userId: \(userId)")
            
            DispatchQueue.main.async {
                self.saveUserData(userId: userId, name: name, email: email)
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Sign in with Apple failed: \(error.localizedDescription)")
    }
}

extension AuthManager: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first else {
            return UIWindow()
        }
        return window
    }
}

struct SignInWithAppleButton: UIViewRepresentable {
    @ObservedObject var authManager = AuthManager.shared
    
    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        let button = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
        button.addTarget(context.coordinator, action: #selector(Coordinator.handleAppleSignIn), for: .touchUpInside)
        return button
    }
    
    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(authManager: authManager)
    }
    
    class Coordinator: NSObject {
        var authManager: AuthManager
        
        init(authManager: AuthManager) {
            self.authManager = authManager
        }
        
        @objc func handleAppleSignIn() {
            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.fullName, .email]
            
            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = authManager
            controller.presentationContextProvider = authManager
            controller.performRequests()
        }
    }
} 