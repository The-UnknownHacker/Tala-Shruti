import SwiftUI

struct FeedbackView: View {
    @Environment(\.dismiss) var dismiss
    @State private var feedbackText = ""
    @State private var showingMailAlert = false
    @State private var showingConfirmation = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Your Feedback")) {
                    TextEditor(text: $feedbackText)
                        .frame(minHeight: 150)
                        .placeholder(when: feedbackText.isEmpty) {
                            Text("Tell us what you think about Tala Shruti...")
                                .foregroundColor(.gray)
                                .padding(.top, 8)
                                .padding(.leading, 5)
                        }
                }
                
                Section {
                    Button(action: sendFeedback) {
                        HStack {
                            Image(systemName: "paperplane.fill")
                            Text("Send Feedback")
                        }
                    }
                    .disabled(feedbackText.isEmpty)
                }
                
                Section {
                    Button(action: {
                        if let url = URL(string: "https://apps.apple.com/app/id6740571964") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text("Rate on App Store")
                        }
                    }
                } footer: {
                    Text("Your ratings help other musicians discover Tala Shruti!")
                }
            }
            .navigationTitle("Feedback")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Cannot Send Email", isPresented: $showingMailAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Your device is not configured to send emails. Please ensure you have an email account set up.")
            }
            .alert("Thank You!", isPresented: $showingConfirmation) {
                Button("OK", role: .cancel) {
                    dismiss()
                }
            } message: {
                Text("Your feedback has been sent. We appreciate your input!")
            }
        }
    }
    
    private func sendFeedback() {
        if !feedbackText.isEmpty {
            FeedbackManager.shared.sendFeedback(email: "", message: feedbackText)
            showingConfirmation = true
        }
    }
}

// Add this extension for the placeholder
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
        
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
} 