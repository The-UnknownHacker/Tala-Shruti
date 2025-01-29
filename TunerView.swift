import SwiftUI

struct TunerView: View {
    @StateObject private var tuner = TunerManager.shared
    @Environment(\.colorScheme) var colorScheme
    
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
    
    private var noteColor: Color {
        let cents = tuner.cents
        if abs(cents) < 3 {
            return .green
        } else if abs(cents) < 10 {
            return .yellow
        } else {
            return .red
        }
    }
    
    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Main Tuner Display
                ZStack {
                    // Outer circle
                    Circle()
                        .stroke(Color.secondary.opacity(0.2), lineWidth: 3)
                        .frame(width: 280, height: 280)
                    
                    // Tuning marks
                    ForEach(-25...25, id: \.self) { i in
                        Rectangle()
                            .fill(Color.secondary)
                            .frame(width: i % 5 == 0 ? 2 : 1, 
                                  height: i % 5 == 0 ? 15 : 10)
                            .offset(y: -130)
                            .rotationEffect(.degrees(Double(i) * 3.6))
                    }
                    
                    // Center mark
                    Rectangle()
                        .fill(Color.secondary)
                        .frame(width: 2, height: 20)
                        .offset(y: -130)
                    
                    // Needle
                    Rectangle()
                        .fill(noteColor)
                        .frame(width: 3, height: 140)
                        .overlay(
                            Circle()
                                .fill(noteColor)
                                .frame(width: 16, height: 16)
                                .offset(y: 65)
                        )
                        .rotationEffect(.degrees(min(45, max(-45, Double(tuner.cents) * 1.8))))
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: tuner.cents)
                    
                    // Note Display
                    VStack(spacing: 5) {
                        Text(tuner.noteNameWithSharps)
                            .font(.system(size: 80, weight: .bold, design: .rounded))
                            .foregroundColor(noteColor)
                            .frame(height: 90)
                            .contentTransition(.numericText())
                        
                        Text("\(Int(round(tuner.pitch)))Hz")
                            .font(.system(.title3, design: .rounded))
                            .foregroundColor(.secondary)
                            .frame(height: 30)
                    }
                    .offset(y: 30)
                }
                .padding(.top, 20)
                
                
                // Input Level Meter
                VStack(spacing: 8) {
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.secondary.opacity(0.2))
                            .frame(height: 8)
                        
                        GeometryReader { geometry in
                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    LinearGradient(
                                        colors: [.blue, .green, .yellow, .red],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * CGFloat(tuner.amplitude))
                        }
                    }
                    .frame(height: 8)
                    .padding(.horizontal)
                    
                    Text("Input Level")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 40)
            }
            .padding()
        }
        .onAppear {
            tuner.start()
        }
        .onDisappear {
            tuner.stop()
        }
    }
}

#Preview {
    TunerView()
} 