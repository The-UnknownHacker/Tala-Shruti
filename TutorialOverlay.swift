import SwiftUI

struct TutorialOverlay: View {
    @ObservedObject var tutorialManager = TutorialManager.shared
    @Environment(\.colorScheme) var colorScheme
    
    private var textColor: Color {
        colorScheme == .dark ? .white : .black
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background with highlight
                TutorialBackground(
                    highlightFrame: tutorialManager.highlightFrame,
                    step: tutorialManager.tutorialSteps[tutorialManager.currentStep],
                    colorScheme: colorScheme
                )
                
                // Tutorial content
                VStack(spacing: 24) {
                    Text(tutorialManager.tutorialSteps[tutorialManager.currentStep].title)
                        .font(.title2.bold())
                        .foregroundColor(textColor)
                    
                    Text(tutorialManager.tutorialSteps[tutorialManager.currentStep].message)
                        .font(.body)
                        .foregroundColor(textColor)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            tutorialManager.nextStep()
                        }
                    }) {
                        Text(tutorialManager.currentStep == tutorialManager.tutorialSteps.count - 1 ? 
                            "Get Started" : "Next")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(minWidth: 44, minHeight: 44)
                            .padding(.horizontal, 30)
                            .background(Color.blue)
                            .cornerRadius(22)
                    }
                }
                .padding(32)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemGray6).opacity(0.95))
                        .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
                )
                .frame(maxWidth: min(geometry.size.width - 64, 400))
                .position(
                    x: geometry.size.width / 2,
                    y: geometry.size.height / 2
                )
            }
            .ignoresSafeArea()
        }
    }
}

struct TutorialBackground: View {
    let highlightFrame: CGRect
    let step: TutorialStep
    let colorScheme: ColorScheme
    
    var body: some View {
        ZStack {
            // Background overlay with different opacity based on color scheme
            Color.black.opacity(colorScheme == .dark ? 0.75 : 0.5)
            
            // Highlight area with pulsing animation
            if step.highlightType != .none {
                RoundedRectangle(cornerRadius: step.highlightType == .button ? 20 : 12)
                    .stroke(Color.blue, lineWidth: 2)
                    .frame(
                        width: highlightFrame.width + 8,
                        height: highlightFrame.height + 8
                    )
                    .position(
                        x: highlightFrame.midX,
                        y: highlightFrame.midY
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: step.highlightType == .button ? 20 : 12)
                            .fill(Color.blue.opacity(0.2))
                            .frame(
                                width: highlightFrame.width + 8,
                                height: highlightFrame.height + 8
                            )
                    )
                    .modifier(PulseAnimation())
            }
        }
    }
}

struct PulseAnimation: ViewModifier {
    @State private var isPulsing = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? 1.05 : 1)
            .opacity(isPulsing ? 0.8 : 1)
            .animation(
                Animation.easeInOut(duration: 1)
                    .repeatForever(autoreverses: true),
                value: isPulsing
            )
            .onAppear {
                isPulsing = true
            }
    }
} 
