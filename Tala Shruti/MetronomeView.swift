import SwiftUI

struct MetronomeView: View {
    @StateObject private var metronome = MetronomeManager.shared
    @State private var showCustomization = false
    @State private var showPresetPicker = false
    @State private var isDragging = false
    @State private var dragOffset: CGFloat = 0
    @State private var previousTempo: Double = 0
    @State private var showTalamPicker = false
    @State private var showJatiPicker = false
    @Environment(\.colorScheme) var colorScheme
    
    private let minTempo: Double = 30
    private let maxTempo: Double = 300
    private let tempoStep: Double = 1
    
    private let jatis = ["Tisra", "Chatusra", "Khanda", "Misra", "Sankeerna"]
    private let talams = ["Dhruva", "Matya", "Rupaka", "Jhampa", "Triputa", "Ata", "Eka"]
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 12) {
                VStack(spacing: 16) {
                    VStack(spacing: 2) {
                        Text("\(metronome.currentBeat + 1)")
                            .font(.system(size: 72, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("Beat")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 12)
                    
                    ZStack {
                        Circle()
                            .fill(Color(.secondarySystemBackground))
                            .frame(width: 160, height: 160)
                        
                        ForEach(0..<metronome.getTotalBeatsCount(), id: \.self) { index in
                            let angle = Double(index) * (360.0 / Double(metronome.getTotalBeatsCount()))
                            let beatType = metronome.getBeatTypeForVisual(at: index)
                            
                            let isCurrent = index == metronome.currentBeat
                            
                            ZStack {
                                if isCurrent {
                                    Circle()
                                        .fill(Color.yellow.opacity(0.6))
                                        .frame(width: 16, height: 16)
                                }
                                
                                Circle()
                                    .fill(getBeatColor(beatType, isCurrent: false))
                                    .frame(width: getBeatSize(beatType), height: getBeatSize(beatType))
                            }
                            .offset(y: -70)
                            .rotationEffect(.degrees(angle))
                        }
                        
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                if metronome.isPlaying {
                                    metronome.stopMetronome()
                                } else {
                                    metronome.startMetronome()
                                }
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(metronome.isPlaying ? Color.red : Color.accentColor)
                                    .frame(width: 50, height: 50)
                                    .shadow(color: (metronome.isPlaying ? Color.red : Color.accentColor).opacity(0.3), radius: 8)
                                
                                Image(systemName: metronome.isPlaying ? "stop.fill" : "play.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .frame(height: 160)
                    
                    HStack(spacing: 16) {
                        Button(action: { metronome.setTempo(metronome.tempo - 5) }) {
                            Image(systemName: "minus.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.accentColor)
                        }
                        .frame(width: 44, height: 44)
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color.secondary.opacity(0.2))
                                    .frame(height: 4)
                                
                                Rectangle()
                                    .fill(Color.accentColor)
                                    .frame(width: CGFloat((metronome.tempo - minTempo) / (maxTempo - minTempo)) * geometry.size.width, height: 4)
                                
                                Circle()
                                    .fill(Color.accentColor)
                                    .frame(width: 32, height: 32)
                                    .offset(x: CGFloat((metronome.tempo - minTempo) / (maxTempo - minTempo)) * geometry.size.width - 16)
                                    .gesture(
                                        DragGesture(minimumDistance: 0)
                                            .onChanged { value in
                                                if !isDragging {
                                                    isDragging = true
                                                    previousTempo = metronome.tempo
                                                }
                                                let percentage = max(0, min(1, value.location.x / geometry.size.width))
                                                let newTempo = minTempo + (maxTempo - minTempo) * percentage
                                                metronome.setTempo(newTempo)
                                                dragOffset = value.location.x
                                            }
                                            .onEnded { _ in
                                                isDragging = false
                                            }
                                    )
                            }
                        }
                        .frame(height: 44)
                        
                        Button(action: { metronome.setTempo(metronome.tempo + 5) }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.accentColor)
                        }
                        .frame(width: 44, height: 44)
                    }
                    .padding(.horizontal)
                    
                    VStack(spacing: 12) {
                        HStack(spacing: 12) {
                            Button(action: { 
                                showTalamPicker.toggle()
                                if showTalamPicker {
                                    showJatiPicker = false
                                }
                            }) {
                                HStack {
                                    Text("Talam: \(metronome.selectedTalam)")
                                        .fontWeight(.medium)
                                    
                                    Image(systemName: "chevron.down")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(8)
                                .frame(minWidth: 0, maxWidth: .infinity)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Button(action: { 
                                showJatiPicker.toggle()
                                if showJatiPicker {
                                    showTalamPicker = false
                                }
                            }) {
                                HStack {
                                    Text("Jati: \(metronome.selectedJati)")
                                        .fontWeight(.medium)
                                    
                                    Image(systemName: "chevron.down")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(8)
                                .frame(minWidth: 0, maxWidth: .infinity)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.horizontal)
                        
                        if showTalamPicker {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Select Talam:")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal)
                                
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 85))], spacing: 10) {
                                    ForEach(talams, id: \.self) { talam in
                                        Button(action: { 
                                            metronome.selectedTalam = talam
                                            showTalamPicker = false
                                        }) {
                                            Text(talam)
                                                .font(.system(size: 14, weight: .medium))
                                                .frame(minWidth: 0, maxWidth: .infinity)
                                                .padding(.vertical, 8)
                                                .background(
                                                    metronome.selectedTalam == talam 
                                                    ? Color.accentColor 
                                                    : Color(.secondarySystemBackground)
                                                )
                                                .foregroundColor(
                                                    metronome.selectedTalam == talam 
                                                    ? .white 
                                                    : .primary
                                                )
                                                .cornerRadius(8)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .padding(.vertical, 8)
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                            .padding(.horizontal)
                            .animation(.easeInOut(duration: 0.2), value: showTalamPicker)
                        }
                        
                        if showJatiPicker {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Select Jati:")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal)
                                
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 85))], spacing: 10) {
                                    ForEach(jatis, id: \.self) { jati in
                                        Button(action: { 
                                            metronome.selectedJati = jati
                                            showJatiPicker = false
                                        }) {
                                            Text(jati)
                                                .font(.system(size: 14, weight: .medium))
                                                .frame(minWidth: 0, maxWidth: .infinity)
                                                .padding(.vertical, 8)
                                                .background(
                                                    metronome.selectedJati == jati 
                                                    ? Color.accentColor 
                                                    : Color(.secondarySystemBackground)
                                                )
                                                .foregroundColor(
                                                    metronome.selectedJati == jati 
                                                    ? .white 
                                                    : .primary
                                                )
                                                .cornerRadius(8)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .padding(.vertical, 8)
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                            .padding(.horizontal)
                            .animation(.easeInOut(duration: 0.2), value: showJatiPicker)
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.bottom, 8)
        }
        .sheet(isPresented: $showPresetPicker) {
            PresetPickerView()
        }
        .sheet(isPresented: $showCustomization) {
            MetronomeCustomizationView()
        }
        .onTapGesture {
            showTalamPicker = false
            showJatiPicker = false
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack {
                    VStack(spacing: 2) {
                        Text("\(Int(metronome.tempo))")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("BPM")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Text("Tala Shruti")
                        .font(.headline)
                    Spacer()
                    VStack(spacing: 2) {
                        Text("")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                        Text("")
                            .font(.caption)
                    }
                }
            }
        }
        .onDisappear {
            metronome.stopMetronome()
        }
        .onAppear {
            metronome.isOnBeatsPage = true
            
            if metronome.isPlaying {
                metronome.startMetronome()
            }
        }
    }
    
    private func getBeatColor(_ type: String, isCurrent: Bool) -> Color {
        switch type {
        case "laghu_start", "drutam_high":
            return Color.red
        case "laghu_count", "drutam_low":
            return Color.gray.opacity(0.4)
        case "anudrutam":
            return Color.orange
        default:
            return Color.secondary.opacity(0.3)
        }
    }
    
    private func getBeatSize(_ type: String) -> CGFloat {
        switch type {
        case "laghu_start", "drutam_high":
            return 10
        case "laghu_count", "drutam_low":
            return 7
        case "anudrutam":
            return 8
        default:
            return 6
        }
    }
    
    private func getTalamPattern(_ talam: String) -> [String] {
        switch talam {
        case "Dhruva":
            return ["sam", "laghu", "drutam", "laghu", "laghu"]
        case "Matya":
            return ["sam", "laghu", "drutam", "laghu"]
        case "Rupaka":
            return ["drutam", "laghu"]
        case "Jhampa":
            return ["sam", "laghu", "anudrutam", "drutam"]
        case "Triputa":
            return ["sam", "laghu", "drutam", "drutam"]
        case "Ata":
            return ["sam", "laghu", "laghu", "drutam", "drutam"]
        case "Eka":
            return ["sam", "laghu"]
        default:
            return ["sam", "laghu"]
        }
    }
    
    private func getTalamDescription(_ talam: String) -> String {
        switch talam {
        case "Dhruva":
            return "Laghu, Drutam, Laghu, Laghu"
        case "Matya":
            return "Laghu, Drutam, Laghu"
        case "Rupaka":
            return "Drutam, Laghu"
        case "Jhampa":
            return "Laghu, Anudrutam, Drutam"
        case "Triputa":
            return "Laghu, Drutam, Drutam"
        case "Ata":
            return "Laghu, Laghu, Drutam, Drutam"
        case "Eka":
            return "Laghu"
        default:
            return ""
        }
    }
    
    private func getJatiDescription(_ jati: String) -> String {
        switch jati {
        case "Tisra":
            return "3 beats per Laghu"
        case "Chatusra":
            return "4 beats per Laghu"
        case "Khanda":
            return "5 beats per Laghu"
        case "Misra":
            return "7 beats per Laghu"
        case "Sankeerna":
            return "9 beats per Laghu"
        default:
            return ""
        }
    }
}

struct PresetPickerView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var metronome = MetronomeManager.shared
    @State private var showingCustomization = false
    
    private let talams = ["Dhruva", "Matya", "Rupaka", "Jhampa", "Triputa", "Ata", "Eka"]
    private let jatis = ["Tisra", "Chatusra", "Khanda", "Misra", "Sankeerna"]
    
    var body: some View {
        NavigationView {
            List {
                Section("Talam Selection") {
                    ForEach(talams, id: \.self) { talam in
                        Button(action: {
                            metronome.selectedTalam = talam
                            if metronome.isPlaying {
                                metronome.stopMetronome()
                                metronome.startMetronome()
                            }
                            dismiss()
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(talam)
                                        .font(.headline)
                                    Text(getTalamDescription(talam))
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                if metronome.selectedTalam == talam {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.accentColor)
                                }
                            }
                            .padding(.vertical, 8)
                            .contentShape(Rectangle())
                        }
                    }
                }
                
                Section("Jati Selection") {
                    ForEach(jatis, id: \.self) { jati in
                        Button(action: {
                            metronome.selectedJati = jati
                            if metronome.isPlaying {
                                metronome.stopMetronome()
                                metronome.startMetronome()
                            }
                            dismiss()
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(jati)
                                        .font(.headline)
                                    Text(getJatiDescription(jati))
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                if metronome.selectedJati == jati {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.accentColor)
                                }
                            }
                            .padding(.vertical, 8)
                            .contentShape(Rectangle())
                        }
                    }
                }
            }
            .navigationTitle("Patterns")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func getTalamDescription(_ talam: String) -> String {
        switch talam {
        case "Dhruva":
            return "Laghu, Drutam, Laghu, Laghu"
        case "Matya":
            return "Laghu, Drutam, Laghu"
        case "Rupaka":
            return "Drutam, Laghu"
        case "Jhampa":
            return "Laghu, Anudrutam, Drutam"
        case "Triputa":
            return "Laghu, Drutam, Drutam"
        case "Ata":
            return "Laghu, Laghu, Drutam, Drutam"
        case "Eka":
            return "Laghu"
        default:
            return ""
        }
    }
    
    private func getJatiDescription(_ jati: String) -> String {
        switch jati {
        case "Tisra":
            return "3 beats per Laghu"
        case "Chatusra":
            return "4 beats per Laghu"
        case "Khanda":
            return "5 beats per Laghu"
        case "Misra":
            return "7 beats per Laghu"
        case "Sankeerna":
            return "9 beats per Laghu"
        default:
            return ""
        }
    }
}

#Preview {
    MetronomeView()
} 
