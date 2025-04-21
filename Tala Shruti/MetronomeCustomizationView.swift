import SwiftUI

struct MetronomeCustomizationView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var metronome = MetronomeManager.shared
    
    private let talams = ["Dhruva", "Matya", "Rupaka", "Jhampa", "Triputa", "Ata", "Eka"]
    private let jatis = ["Tisra", "Chatusra", "Khanda", "Misra", "Sankeerna"]
    
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
                    
                    Slider(value: Binding(
                        get: { metronome.tempo },
                        set: { metronome.setTempo($0) }
                    ), in: 30...300, step: 1)
                }
                
                Section(header: Text("Talam Selection")) {
                    Picker("Talam", selection: $metronome.selectedTalam) {
                        ForEach(talams, id: \.self) { talam in
                            Text(talam).tag(talam)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    Text(getTalamDescription(metronome.selectedTalam))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section(header: Text("Jati Selection")) {
                    Picker("Jati", selection: $metronome.selectedJati) {
                        ForEach(jatis, id: \.self) { jati in
                            Text(jati).tag(jati)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    Text(getJatiDescription(metronome.selectedJati))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section(header: Text("Sound Configuration")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Total Beats: \(metronome.getTotalBeats())")
                            .font(.subheadline)
                        
                        Text("Beat Types:")
                            .font(.subheadline)
                        
                        if getTalamPattern(metronome.selectedTalam).contains("laghu") {
                            HStack {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 10, height: 10)
                                
                                Text("Laghu Start")
                                    .font(.subheadline)
                                
                                Text("(High click)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 4)
                            
                            HStack {
                                Circle()
                                    .fill(Color.gray.opacity(0.4))
                                    .frame(width: 7, height: 7)
                                
                                Text("Laghu Count")
                                    .font(.subheadline)
                                
                                Text("(Low internal beats)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 4)
                            .padding(.leading, 20)
                        }
                        
                        if getTalamPattern(metronome.selectedTalam).contains("drutam") {
                            HStack {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 10, height: 10)
                                
                                Text("Drutam High")
                                    .font(.subheadline)
                                
                                Circle()
                                    .fill(Color.gray.opacity(0.4))
                                    .frame(width: 7, height: 7)
                                    .padding(.leading, 8)
                                
                                Text("Drutam Low")
                                    .font(.subheadline)
                            }
                            .padding(.vertical, 4)
                            
                            Text("(Alternating high-low clicks)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.vertical, 4)
                                .padding(.leading, 20)
                        }
                        
                        if getTalamPattern(metronome.selectedTalam).contains("anudrutam") {
                            HStack {
                                Circle()
                                    .fill(Color.orange)
                                    .frame(width: 8, height: 8)
                                
                                Text("Anudrutam")
                                    .font(.subheadline)
                                
                                Text("× 1 beat")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                        
                        Divider()
                            .padding(.vertical, 8)
                        
                        Text("Example Pattern:")
                            .font(.subheadline)
                            .padding(.bottom, 4)
                        
                        if metronome.selectedTalam == "Ata" && metronome.selectedJati == "Sankeerna" {
                            HStack(spacing: 4) {
                                Text("Sankeerna Jati + Ata Talam (22 beats):")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.bottom, 2)
                            
                            HStack(spacing: 4) {
                                Text("9 beats")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.2))
                                    .cornerRadius(4)
                                
                                Text("+")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text("9 beats")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.2))
                                    .cornerRadius(4)
                                
                                Text("+")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text("4 beats")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.green.opacity(0.2))
                                    .cornerRadius(4)
                            }
                            .padding(.bottom, 2)
                            
                            HStack(spacing: 4) {
                                ForEach(0..<metronome.getTotalBeats(), id: \.self) { index in
                                    let beatType = metronome.getBeatTypeForVisual(at: index)
                                    if beatType == "laghu_start" || beatType == "drutam_high" {
                                        Text("•")
                                            .font(.caption.bold())
                                            .foregroundColor(.red)
                                            .frame(width: 12)
                                    } else {
                                        Text("•")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                            .frame(width: 12)
                                    }
                                }
                            }
                            .padding(.bottom, 2)
                            
                            HStack(spacing: 4) {
                                Text("High")
                                    .font(.caption)
                                    .bold()
                                    .foregroundColor(.red)
                                
                                Text("low low low low low low low low")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text("High")
                                    .font(.caption)
                                    .bold()
                                    .foregroundColor(.red)
                                
                                Text("low low low low low low low low")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text("High")
                                    .font(.caption)
                                    .bold()
                                    .foregroundColor(.red)
                                
                                Text("low")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text("High")
                                    .font(.caption)
                                    .bold()
                                    .foregroundColor(.red)
                                
                                Text("low")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        } else {
                            let jatiCount = getJaatiCount(metronome.selectedJati)
                            let pattern = getTalamPattern(metronome.selectedTalam)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 4) {
                                    Text("\(metronome.selectedJati) Jati + \(metronome.selectedTalam) Talam (\(metronome.getTotalBeats()) beats):")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.bottom, 2)
                                
                                HStack(spacing: 4) {
                                    ForEach(pattern, id: \.self) { beatType in
                                        if beatType == "laghu" {
                                            Text("\(jatiCount) beats")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(Color.blue.opacity(0.2))
                                                .cornerRadius(4)
                                        } else if beatType == "drutam" {
                                            Text("2 beats")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(Color.green.opacity(0.2))
                                                .cornerRadius(4)
                                        } else if beatType == "anudrutam" {
                                            Text("1 beat")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(Color.orange.opacity(0.2))
                                                .cornerRadius(4)
                                        }
                                        
                                        if pattern.last != beatType {
                                            Text("+")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                                .padding(.bottom, 2)
                            }
                        }
                    }
                    .padding(.vertical, 8)
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
    
    private func getJaatiCount(_ jati: String) -> Int {
        switch jati {
        case "Tisra": return 3
        case "Chatusra": return 4
        case "Khanda": return 5
        case "Misra": return 7
        case "Sankeerna": return 9
        default: return 4
        }
    }
    
    private func getTalamPattern(_ talam: String) -> [String] {
        switch talam {
        case "Dhruva":
            return ["laghu", "drutam", "laghu", "laghu"]
        case "Matya":
            return ["laghu", "drutam", "laghu"]
        case "Rupaka":
            return ["drutam", "laghu"]
        case "Jhampa":
            return ["laghu", "anudrutam", "drutam"]
        case "Triputa":
            return ["laghu", "drutam", "drutam"]
        case "Ata":
            return ["laghu", "laghu", "drutam", "drutam"]
        case "Eka":
            return ["laghu"]
        default:
            return ["laghu"]
        }
    }
    
    private func getBeatColor(_ type: String) -> Color {
        switch type {
        case "sam":
            return Color.red
        case "laghu":
            return Color.blue
        case "drutam":
            return Color.green
        case "anudrutam":
            return Color.orange
        default:
            return Color.secondary
        }
    }
}

#Preview {
    MetronomeCustomizationView()
} 