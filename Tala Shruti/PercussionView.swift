import SwiftUI

struct PercussionView: View {
    @StateObject private var percussion = PercussionManager.shared
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
    
    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Text("\(Int(percussion.tempo))")
                        .font(.system(size: 72, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("BPM")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 24) {
                        Button(action: { percussion.setTempo(percussion.tempo - 5) }) {
                            Image(systemName: "minus.circle.fill")
                                .font(.title)
                                .foregroundColor(.blue)
                        }
                        .frame(width: 44, height: 44)
                        
                        Slider(
                            value: Binding(
                                get: { percussion.tempo },
                                set: { percussion.setTempo($0) }
                            ),
                            in: 30...300,
                            step: 1
                        )
                        .tint(.blue)
                        .frame(maxWidth: 200)
                        
                        Button(action: { percussion.setTempo(percussion.tempo + 5) }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title)
                                .foregroundColor(.blue)
                        }
                        .frame(width: 44, height: 44)
                    }
                }
                
                Picker("Instrument", selection: .init(
                    get: { percussion.selectedInstrument },
                    set: { _ in percussion.toggleInstrument() }
                )) {
                    Text("Tabla").tag("Tabla")
                    Text("Mridangam").tag("Mridangam")
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                Spacer()
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 20) {
                    ForEach(0..<4) { index in
                        PercussionButton(index: index)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top, 16)
        }
        .onAppear {
            percussion.isOnPercussionPage = true
        }
        .onDisappear {
            percussion.stopPlaying()
        }
    }
}

struct PercussionButton: View {
    let index: Int
    @StateObject private var percussion = PercussionManager.shared
    
    private var isActive: Bool {
        percussion.activeButton == index
    }
    
    var body: some View {
        Button(action: {
            percussion.toggleSound(index)
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(isActive ? Color.blue : Color(.systemGray6))
                    .frame(height: 100)
                
                VStack(spacing: 8) {
                    Text("\(index + 1)")
                        .font(.title.bold())
                        .foregroundColor(isActive ? .white : .primary)
                    
                    Text(isActive ? "Playing" : "Tap to Play")
                        .font(.caption)
                        .foregroundColor(isActive ? .white.opacity(0.8) : .secondary)
                }
            }
        }
    }
}

#Preview {
    PercussionView()
} 