import SwiftUI

struct MetronomeView: View {
    @StateObject private var metronome = MetronomeManager.shared
    @State private var showCustomization = false
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
            
            VStack {
                // Tempo Section
                VStack(spacing: 16) {
                    Text("\(Int(metronome.tempo))")
                        .font(.system(size: 72, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("BPM")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    
                    // Tempo Controls
                    HStack(spacing: 24) {
                        Button(action: { metronome.setTempo(metronome.tempo - 5) }) {
                            Image(systemName: "minus.circle.fill")
                                .font(.title)
                                .foregroundColor(.blue)
                        }
                        .frame(width: 44, height: 44)
                        
                        Slider(
                            value: Binding(
                                get: { metronome.tempo },
                                set: { metronome.setTempo($0) }
                            ),
                            in: 30...300,
                            step: 1
                        )
                        .tint(.blue)
                        .frame(maxWidth: 200)
                        
                        Button(action: { metronome.setTempo(metronome.tempo + 5) }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title)
                                .foregroundColor(.blue)
                        }
                        .frame(width: 44, height: 44)
                    }
                }
                .padding(.top, 16)
                
                Spacer()
                    .frame(height: 40)
                
                // Presets Section
                VStack(alignment: .leading, spacing: 24) {
                    // Default Presets
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Default Presets")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(metronome.presets.filter { !$0.isCustom }) { preset in
                                    PresetButton(preset: preset)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Custom Presets (if any exist)
                    if !metronome.presets.filter({ $0.isCustom }).isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Custom Presets")
                                .font(.headline)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(metronome.presets.filter { $0.isCustom }) { preset in
                                        PresetButton(preset: preset)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                .frame(maxHeight: 280)
                
                Spacer()
                
                // Play/Stop Button
                Button(action: {
                    if metronome.isPlaying {
                        metronome.stopMetronome()
                    } else {
                        metronome.startMetronome()
                    }
                }) {
                    Circle()
                        .fill(metronome.isPlaying ? .red : .blue)
                        .frame(width: 72, height: 72)
                        .overlay(
                            Image(systemName: metronome.isPlaying ? "stop.fill" : "play.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.white)
                        )
                        .shadow(radius: 3)
                }
                .padding(.bottom, 40)
                .padding(.top, -40)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showCustomization.toggle() }) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.body)
                        .frame(width: 44, height: 44)
                }
            }
        }
        .sheet(isPresented: $showCustomization) {
            MetronomeCustomizationView()
        }
    }
}

struct PresetButton: View {
    let preset: TalamPreset
    @StateObject private var metronome = MetronomeManager.shared
    
    var body: some View {
        Button(action: {
            metronome.selectedPreset = preset
            if metronome.isPlaying {
                metronome.stopMetronome()
                metronome.startMetronome()
            }
        }) {
            VStack(alignment: .leading, spacing: 6) {
                Text(preset.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(preset.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(width: 140, height: 70)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(metronome.selectedPreset?.id == preset.id ?
                          Color.blue.opacity(0.2) : Color(.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(metronome.selectedPreset?.id == preset.id ?
                           Color.blue : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
} 