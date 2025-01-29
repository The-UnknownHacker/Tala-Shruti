import SwiftUI
import StoreKit

class FeedbackManager: ObservableObject {
    static let shared = FeedbackManager()
    
    private let defaults = UserDefaults.standard
    private let appLaunchesKey = "numberOfAppLaunches"
    private let lastRatingPromptKey = "lastRatingPromptDate"
    private let minimumLaunchesForRating = 5
    private let minimumDaysBetweenPrompts = 60.0 // 60 days
    
    func incrementAppLaunches() {
        let currentLaunches = defaults.integer(forKey: appLaunchesKey)
        defaults.set(currentLaunches + 1, forKey: appLaunchesKey)
        
        checkAndRequestReview()
    }
    
    private func checkAndRequestReview() {
        let launches = defaults.integer(forKey: appLaunchesKey)
        let lastPromptDate = defaults.object(forKey: lastRatingPromptKey) as? Date ?? Date.distantPast
        
        let daysSinceLastPrompt = Date().timeIntervalSince(lastPromptDate) / (24 * 60 * 60)
        
        if launches >= minimumLaunchesForRating && daysSinceLastPrompt >= minimumDaysBetweenPrompts {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    SKStoreReviewController.requestReview(in: scene)
                    self.defaults.set(Date(), forKey: self.lastRatingPromptKey)
                }
            }
        }
    }
    
    func sendFeedback(email: String, message: String) {
        guard let emailURL = createEmailUrl(email: "jhamb.aarav@gmail.com",
                                          subject: "Tala Shruti Feedback",
                                          body: message) else { return }
        UIApplication.shared.open(emailURL)
    }
    
    private func createEmailUrl(email: String, subject: String, body: String) -> URL? {
        let subjectEncoded = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let bodyEncoded = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        let gmailUrl = URL(string: "googlegmail://co?to=\(email)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
        let outlookUrl = URL(string: "ms-outlook://compose?to=\(email)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
        let defaultUrl = URL(string: "mailto:\(email)?subject=\(subjectEncoded)&body=\(bodyEncoded)")
        
        if let gmailUrl = gmailUrl, UIApplication.shared.canOpenURL(gmailUrl) {
            return gmailUrl
        } else if let outlookUrl = outlookUrl, UIApplication.shared.canOpenURL(outlookUrl) {
            return outlookUrl
        }
        
        return defaultUrl
    }
} 