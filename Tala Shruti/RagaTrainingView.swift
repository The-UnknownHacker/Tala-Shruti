import SwiftUI

struct RagaTrainingView: View {
    @StateObject private var manager = RagaTrainingManager()
    @Environment(\.colorScheme) var colorScheme
    @State private var showShrutiPicker = false
    @State private var showRagaPicker = false
    
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
    
    private var progressPercentage: Double {
        guard !manager.selectedRaga.notes.isEmpty else { return 0 }
        return Double(manager.completedNotes.count) / Double(manager.selectedRaga.notes.count)
    }
    
    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                VStack(spacing: 8) {
                    Button(action: { showRagaPicker.toggle() }) {
                        HStack {
                            Text(manager.selectedRaga.name)
                                .font(.title3)
                                .fontWeight(.bold)
                            Image(systemName: "chevron.down")
                                .font(.caption)
                        }
                        .foregroundColor(.primary)
                    }
                    
                    HStack(spacing: 12) {
                        Button(action: { showShrutiPicker.toggle() }) {
                            HStack(spacing: 6) {
                                Image(systemName: "music.note")
                                    .font(.caption)
                                Text(manager.selectedShruti.displayName)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(12)
                        }
                        
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(.green)
                            Text("\(manager.completedNotes.count)/\(manager.selectedRaga.notes.count)")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.green.opacity(0.2))
                        .cornerRadius(12)
                    }
                }
                .padding(.top, 10)
                
                VStack(spacing: 8) {
                    ForEach(Array(manager.selectedRaga.notes.enumerated()), id: \.element.id) { index, note in
                        NoteCard(
                            note: note,
                            isActive: index == manager.currentNoteIndex,
                            isCompleted: manager.completedNotes.contains(index),
                            detectedFrequency: manager.detectedFrequency
                        )
                    }
                }
                .padding(.horizontal)
                
                VStack(spacing: 12) {
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
                                .frame(width: geometry.size.width * CGFloat(manager.amplitude))
                        }
                    }
                    .frame(height: 8)
                    .padding(.horizontal)
                    
                    Text("Input Level")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if manager.isComplete {
                        Button(action: {
                            manager.reset()
                        }) {
                            Text("Practice Again")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 20)
            }
        }
        .sheet(isPresented: $showShrutiPicker) {
            ShrutiPickerView(selectedShruti: $manager.selectedShruti)
                .onDisappear {
                    manager.updateShruti(manager.selectedShruti)
                }
        }
        .sheet(isPresented: $showRagaPicker) {
            RagaPickerView(selectedRaga: $manager.baseRaga)
                .onDisappear {
                    manager.updateRaga(manager.baseRaga)
                }
        }
        .onAppear {
            print("RagaTrainingView appeared - starting manager")
            manager.updateShruti(manager.selectedShruti)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                AudioManager.shared.configureForTunerPage()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    manager.start()
                }
            }
        }
        .onDisappear {
            print("RagaTrainingView disappeared - stopping manager")
            manager.stop()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                AudioManager.shared.configureForMainPage()
            }
        }
    }
}

struct NoteCard: View {
    let note: RagaNote
    let isActive: Bool
    let isCompleted: Bool
    let detectedFrequency: Float
    
    private var matchPercentage: Double {
        guard isActive else { return 0 }
        
        let ratio = detectedFrequency / note.frequency
        let octaveAdjustedFreq: Float
        
        if ratio > 1.8 {
            octaveAdjustedFreq = detectedFrequency / 4
        } else if ratio > 1.4 {
            octaveAdjustedFreq = detectedFrequency / 2
        } else if ratio < 0.6 {
            octaveAdjustedFreq = detectedFrequency * 2
        } else if ratio < 0.3 {
            octaveAdjustedFreq = detectedFrequency * 4
        } else {
            octaveAdjustedFreq = detectedFrequency
        }
        
        let difference = abs(octaveAdjustedFreq - note.frequency)
        let tolerance: Float = 15.0
        
        if difference < tolerance {
            return Double(1.0 - (difference / tolerance))
        }
        return 0
    }
    
    private var cardColor: Color {
        if isCompleted {
            return .green
        } else if isActive {
            if matchPercentage > 0.7 {
                return .green.opacity(0.3)
            } else if matchPercentage > 0.4 {
                return .yellow.opacity(0.3)
            }
            return .blue.opacity(0.3)
        }
        return Color(.secondarySystemBackground)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Text(note.swaraName)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(isCompleted ? .white : .primary)
                .frame(width: 60)
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(Int(note.frequency)) Hz")
                    .font(.caption)
                    .foregroundColor(isCompleted ? .white : .primary)
                
                if isActive && !isCompleted {
                    Text("\(Int(detectedFrequency)) Hz")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            if isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title3)
                    .foregroundColor(.white)
            } else if isActive {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 10, height: 10)
                    .overlay(
                        Circle()
                            .stroke(Color.blue, lineWidth: 2)
                            .scaleEffect(1.5)
                            .opacity(0.5)
                    )
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(cardColor)
                .shadow(color: isActive ? .blue.opacity(0.3) : .clear, radius: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(
                    isActive ? Color.blue : Color.clear,
                    lineWidth: 2
                )
        )
        .animation(.easeInOut(duration: 0.3), value: isActive)
        .animation(.easeInOut(duration: 0.3), value: isCompleted)
    }
}

struct ShrutiPickerView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedShruti: SoundAsset
    
    let shrutis: [SoundAsset] = [
        .C, .CSharp, .D, .DSharp, .E, .F,
        .FSharp, .G, .GSharp, .A, .ASharp, .B
    ]
    
    var body: some View {
        NavigationView {
            List(shrutis, id: \.rawValue) { shruti in
                Button(action: {
                    selectedShruti = shruti
                    dismiss()
                }) {
                    HStack {
                        Text(shruti.displayName)
                            .font(.title2)
                        Spacer()
                        if selectedShruti == shruti {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationTitle("Select Shruti")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct RagaPickerView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedRaga: Raga
    
    var body: some View {
        NavigationView {
            List(Raga.allRagas, id: \.id) { raga in
                Button(action: {
                    selectedRaga = raga
                    dismiss()
                }) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(raga.name)
                                .font(.title3)
                                .fontWeight(.semibold)
                            Spacer()
                            if selectedRaga.name == raga.name {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        Text(raga.notes.map { $0.swaraName }.joined(separator: " - "))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Select Raga")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    RagaTrainingView()
}
