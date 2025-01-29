import SwiftUI

struct MetronomeCustomizationView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var metronome = MetronomeManager.shared
    @State private var showingAddPreset = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Tempo")) {
                    HStack {
                        Text("\(Int(metronome.tempo)) BPM")
                        Spacer()
                        Button("-") {
                            metronome.setTempo(metronome.tempo - 1)
                        }
                        .buttonStyle(.bordered)
                        Button("+") {
                            metronome.setTempo(metronome.tempo + 1)
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    Stepper("Tap to adjust by 5", value: Binding(
                        get: { metronome.tempo },
                        set: { metronome.setTempo($0) }
                    ), in: 30...300, step: 5)
                }
                
                Section(header: Text("Sound")) {
                    HStack {
                        Text("Volume")
                        Slider(value: .constant(1.0)) // TODO: Implement volume control
                    }
                }
                
                if !metronome.presets.filter({ $0.isFavorite }).isEmpty {
                    Section(header: Text("Favorites")) {
                        ForEach(metronome.presets.filter { $0.isFavorite }) { preset in
                            PresetRow(preset: preset)
                        }
                    }
                }
                
                Section(header: Text("Default Presets")) {
                    ForEach(metronome.presets.filter { !$0.isCustom }) { preset in
                        PresetRow(preset: preset)
                    }
                }
                
                if !metronome.presets.filter({ $0.isCustom }).isEmpty {
                    Section(header: Text("Custom Presets")) {
                        ForEach(metronome.presets.filter { $0.isCustom }) { preset in
                            PresetRow(preset: preset)
                        }
                        .onDelete { indices in
                            indices.forEach { index in
                                let customPresets = metronome.presets.filter { $0.isCustom }
                                metronome.deletePreset(customPresets[index])
                            }
                        }
                    }
                }
                
                Section {
                    Button(action: { showingAddPreset = true }) {
                        Label("Add Custom Preset", systemImage: "plus.circle.fill")
                    }
                }
            }
            .navigationTitle("Customize")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingAddPreset) {
                AddPresetView()
            }
        }
    }
}

struct PresetRow: View {
    let preset: TalamPreset
    @StateObject private var metronome = MetronomeManager.shared
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(preset.name)
                    .font(.headline)
                Text(preset.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: {
                metronome.toggleFavorite(preset)
            }) {
                Image(systemName: preset.isFavorite ? "star.fill" : "star")
                    .foregroundColor(preset.isFavorite ? .yellow : .gray)
            }
            
            if metronome.selectedPreset?.id == preset.id {
                Image(systemName: "checkmark")
                    .foregroundColor(.blue)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            metronome.selectedPreset = preset
            if metronome.isPlaying {
                metronome.stopMetronome()
                metronome.startMetronome()
            }
        }
    }
}

struct AddPresetView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var metronome = MetronomeManager.shared
    @State private var name = ""
    @State private var beats = 8
    @State private var accentPattern: [Bool] = Array(repeating: false, count: 16)
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Preset Name", text: $name)
                    Stepper("Beats: \(beats)", value: $beats, in: 2...16) { _ in
                        if accentPattern.count < beats {
                            accentPattern.append(contentsOf: Array(repeating: false, count: beats - accentPattern.count))
                        }
                    }
                }
                
                Section(header: Text("Accent Pattern")) {
                    ForEach(0..<beats, id: \.self) { index in
                        Toggle("Beat \(index + 1)", isOn: Binding(
                            get: { index < accentPattern.count ? accentPattern[index] : false },
                            set: { newValue in
                                if index < accentPattern.count {
                                    accentPattern[index] = newValue
                                }
                            }
                        ))
                    }
                }
            }
            .navigationTitle("New Preset")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let newPreset = TalamPreset(
                            name: name,
                            beats: beats,
                            accentPattern: Array(accentPattern.prefix(beats)),
                            description: "\(beats) beats",
                            isCustom: true
                        )
                        metronome.addCustomPreset(newPreset)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

#Preview {
    MetronomeCustomizationView()
} 