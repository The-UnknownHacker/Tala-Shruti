import SwiftUI

class TutorialManager: ObservableObject {
    static let shared = TutorialManager()
    
    @Published var showTutorial = false
    @Published var currentStep = 0
    @Published var highlightFrame: CGRect = .zero
    
    let tutorialSteps = [
        TutorialStep(
            title: "Welcome to Tala Shruti",
            message: "Swipe left/right to switch between Shruti Box, Metronome, and Percussion",
            highlightType: .none
        ),
        TutorialStep(
            title: "Shruti Box",
            message: "Tap any note to play. Adjust volume using the slider.",
            highlightType: .button
        ),
        TutorialStep(
            title: "Volume Control",
            message: "Use this slider to adjust the volume",
            highlightType: .slider
        ),
        TutorialStep(
            title: "Settings",
            message: "Access settings to change themes and enable Madhyamamam mode",
            highlightType: .settings
        ),
        TutorialStep(
            title: "Metronome",
            message: "Swipe left for the metronome. Create custom patterns and adjust tempo.",
            highlightType: .none
        ),
        TutorialStep(
            title: "Percussion",
            message: "Swipe again for percussion. Choose between Tabla and Mridangam, and tap any button to play loops.",
            highlightType: .none
        ),
        TutorialStep(
            title: "Tuner",
            message: "Swipe again for the tuner. Play any note to detect its pitch and frequency.",
            highlightType: .none
        )
    ]
    
    func startTutorial() {
        currentStep = 0
        showTutorial = true
        UserDefaults.standard.set(true, forKey: "hasSeenTutorial")
    }
    
    func nextStep() {
        if currentStep < tutorialSteps.count - 1 {
            currentStep += 1
        } else {
            showTutorial = false
        }
    }
    
    func updateHighlightFrame(_ frame: CGRect) {
        highlightFrame = frame
    }
}

struct TutorialStep {
    let title: String
    let message: String
    let highlightType: HighlightType
}

enum HighlightType {
    case none
    case button
    case slider
    case settings
} 