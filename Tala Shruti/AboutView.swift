import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showFeedback = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    VStack(spacing: 16) {
                        Image(systemName: "music.note.list")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                            .padding(.top, 20)
                        
                        Text("Tala Shruti")
                            .font(.title.bold())
                        
                        Text("Version 1.0")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                }
                
                Section {
                    Text("Tala Shruti is a digital shruti box app designed for Indian classical music practice. It provides precise shruti (musical note) playback with adjustable volume and background playback capabilities.")
                }
                
                Section(header: Text("Features")) {
                    FeatureRow(icon: "music.note", title: "12 Shrutis", description: "Full chromatic scale support")
                    FeatureRow(icon: "waveform", title: "Madhyamam Mode", description: "Alternative tuning option")
                    FeatureRow(icon: "speaker.wave.3", title: "Volume Control", description: "Adjustable audio levels")
                    FeatureRow(icon: "play.circle", title: "Background Play", description: "Continue playback when app is minimized")
                    FeatureRow(icon: "paintbrush", title: "Themes", description: "Multiple color themes and appearance modes")
                    FeatureRow(icon: "metronome", title: "Tala Metronome", description: "Customizable rhythm patterns")
                    FeatureRow(icon: "waveform.circle", title: "Percussion", description: "Tabla and Mridangam loops with tempo control")
                    FeatureRow(icon: "tuningfork", title: "Tuner", description: "Real-time pitch detection for instruments")
                    FeatureRow(icon: "lyrics", title: "Lyrics", description: "Lyrics for any song any time")

                }
                
                Section(header: Text("About")) {
                    Text("Created by Aarav J")
                    Link("Contact Support", destination: URL(string: "mailto:jhamb.aarav@gmail.com")!)
                        .foregroundColor(.blue)
                }
                
                Section(header: Text("Legal")) {
                    Text("© 2025 Aarav J. All rights reserved.")
                        .foregroundColor(.secondary)
                        .font(.footnote)
                }
                
                Section {
                    Button(action: {
                        showFeedback.toggle()
                    }) {
                        HStack {
                            Image(systemName: "envelope.fill")
                            Text("Send Feedback")
                        }
                    }
                } header: {
                    Text("Feedback")
                } footer: {
                    Text("We value your feedback! Let us know how we can improve.")
                }
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showFeedback) {
            FeedbackView()
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 30)
                .foregroundColor(.blue)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    AboutView()
} 