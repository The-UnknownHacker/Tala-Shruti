import SwiftUI
import AVFoundation

enum ThemeColor: String, CaseIterable {
    case blue = "Blue"
    case purple = "Purple"
    case green = "Green"
    case orange = "Orange"
    case red = "Red"
    case white = "White/Black"
    
    var color: Color {
        switch self {
        case .blue: return .blue
        case .purple: return .purple
        case .green: return .green
        case .orange: return .orange
        case .red: return .red
        case .white: return .white
        }
    }
}

enum ColorSchemeMode: String, CaseIterable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
}

struct ShrutiBoxView: View {
    @StateObject private var audioManager = AudioManager.shared
    @State private var isPlaying = false
    @State private var useMadhyamam: Bool
    @State private var audioPlayer: AVAudioPlayer?
    @State private var selectedShruti: SoundAsset?
    @State private var showSettings = false
    @State private var activeTheme: ThemeColor
    @State private var colorSchemeMode: ColorSchemeMode
    @Environment(\.colorScheme) var systemColorScheme
    @State private var volume: Double
    @State private var backgroundPlayback: Bool
    
    // Initialize with saved preferences
    init() {
        let defaults = UserDefaultsManager.shared
        _activeTheme = State(initialValue: defaults.loadTheme())
        _colorSchemeMode = State(initialValue: defaults.loadColorScheme())
        _useMadhyamam = State(initialValue: defaults.loadMadhyamam())
        _volume = State(initialValue: defaults.loadVolume())
        _backgroundPlayback = State(initialValue: defaults.loadBackgroundPlayback())
    }
    
    let shrutis: [SoundAsset] = [
        .C, .CSharp, .D, .DSharp, .E, .F,
        .FSharp, .G, .GSharp, .A, .ASharp, .B
    ]
    
    // Three columns for better layout on larger devices
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    // Compute the effective color scheme
    private var effectiveColorScheme: ColorScheme {
        switch colorSchemeMode {
        case .system: return systemColorScheme
        case .light: return .light
        case .dark: return .dark
        }
    }
    
    private var backgroundColor: LinearGradient {
        let isDark = effectiveColorScheme == .dark
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
        NavigationView {
            ZStack {
                backgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: 32) {
                    // Volume Slider
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "speaker.fill")
                            Slider(value: $volume, in: 0...1)
                            Image(systemName: "speaker.wave.3.fill")
                        }
                        .padding(.horizontal)
                    }
                    
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(shrutis, id: \.rawValue) { shruti in
                            Button(action: {
                                toggleShruti(shruti)
                            }) {
                                VStack(spacing: 8) {
                                    Text(displayName(for: shruti))
                                        .font(.system(size: 28, weight: .bold, design: .rounded))
                                        .foregroundColor(getTextColor(for: shruti))
                                    if selectedShruti == shruti && isPlaying {
                                        Text(useMadhyamam ? "Madhyamam" : "Playing")
                                            .font(.caption)
                                            .foregroundColor(getTextColor(for: shruti))
                                    }
                                }
                                .frame(minWidth: 90, minHeight: 90)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(buttonBackground(for: shruti))
                                        .shadow(
                                            color: (selectedShruti == shruti ? 
                                                activeTheme.color.opacity(0.3) : 
                                                Color.black.opacity(0.1)),
                                            radius: selectedShruti == shruti ? 10 : 5,
                                            y: 2
                                        )
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .strokeBorder(
                                            effectiveColorScheme == .dark ? 
                                                .white.opacity(0.2) : 
                                                .black.opacity(0.1),
                                            lineWidth: 1
                                        )
                                )
                            }
                            .buttonStyle(PressableButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Tala Shruti")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showSettings.toggle() }) {
                        Image(systemName: "gear")
                            .font(.system(size: 20, weight: .regular))
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(
                    useMadhyamam: $useMadhyamam,
                    activeTheme: $activeTheme,
                    colorSchemeMode: $colorSchemeMode,
                    volume: $volume,
                    backgroundPlayback: $backgroundPlayback
                )
            }
        }
        .onChange(of: activeTheme) { _ in savePreferences() }
        .onChange(of: colorSchemeMode) { _ in savePreferences() }
        .onChange(of: useMadhyamam) { _ in savePreferences() }
        .onChange(of: volume) { newValue in
            audioPlayer?.volume = Float(newValue)
            savePreferences()
        }
        .onChange(of: backgroundPlayback) { newValue in
            audioManager.enableBackgroundPlayback(newValue)
            savePreferences()
        }
        .preferredColorScheme(colorSchemeMode == .system ? nil : 
            colorSchemeMode == .dark ? .dark : .light)
    }
    
    private func buttonBackground(for shruti: SoundAsset) -> Color {
        if selectedShruti == shruti && isPlaying {
            if activeTheme == .white {
                // Use white in dark mode, black in light mode
                return effectiveColorScheme == .dark ? 
                    Color.white : 
                    Color.black
            }
            return useMadhyamam ? activeTheme.color.opacity(0.8) : activeTheme.color
        }
        return effectiveColorScheme == .dark ? Color(white: 0.3) : Color(.systemGray5)
    }
    
    private func displayName(for shruti: SoundAsset) -> String {
        String(describing: shruti).replacingOccurrences(of: "Sharp", with: "#")
    }
    
    private func toggleShruti(_ note: SoundAsset) {
        // If the same note is playing, stop it
        if selectedShruti == note && isPlaying {
            stopPlaying()
            return
        }
        
        // Otherwise, play the new note
        playShruti(note)
    }
    
    private func playShruti(_ note: SoundAsset) {
        stopPlaying()
        
        let filename = useMadhyamam ? "\(note)_madhyamam" : String(describing: note)
        
        // Debug print to check what file we're looking for
        print("Looking for file: \(filename).wav")
        
        // First try to get the URL and print it
        if let url = Bundle.main.url(forResource: filename, withExtension: "wav") {
            print("Found file at: \(url)")
            
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.prepareToPlay() // Pre-load the audio
                audioPlayer?.numberOfLoops = -1 // Loop indefinitely
                audioPlayer?.volume = Float(volume)  // Set initial volume
                
                if audioPlayer?.play() == true {
                    audioPlayer?.volume = Float(volume)  // Set initial volume
                    isPlaying = true
                    selectedShruti = note
                    print("Successfully started playback")
                } else {
                    print("Failed to start playback")
                }
            } catch {
                print("Could not create audio player: \(error)")
            }
        } else {
            // If file not found, let's print the bundle contents to debug
            print("File not found: \(filename).wav")
            print("Bundle contents:")
            if let resourcePath = Bundle.main.resourcePath {
                let enumerator = FileManager.default.enumerator(atPath: resourcePath)
                while let filePath = enumerator?.nextObject() as? String {
                    if filePath.hasSuffix("wav") {
                        print(filePath)
                    }
                }
            }
        }
    }
    
    private func stopPlaying() {
        audioPlayer?.stop()
        isPlaying = false
        selectedShruti = nil
    }
    
    private func getTextColor(for shruti: SoundAsset) -> Color {
        if selectedShruti == shruti && isPlaying {
            if activeTheme == .white {
                // If white theme: use black text in dark mode, white text in light mode
                return effectiveColorScheme == .dark ? .black : .white
            }
            return .white  // Default white text for other colored buttons
        }
        return effectiveColorScheme == .dark ? .white : .black  // Normal state text color
    }
    
    func savePreferences() {
        UserDefaultsManager.shared.savePreferences(
            theme: activeTheme,
            colorScheme: colorSchemeMode,
            useMadhyamam: useMadhyamam,
            volume: volume,
            backgroundPlayback: backgroundPlayback
        )
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @Binding var useMadhyamam: Bool
    @Binding var activeTheme: ThemeColor
    @Binding var colorSchemeMode: ColorSchemeMode
    @Binding var volume: Double
    @Binding var backgroundPlayback: Bool
    
    private func themeColor(_ theme: ThemeColor) -> Color {
        if theme == .white {
            return colorScheme == .dark ? .white : .black
        }
        return theme.color
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Toggle("Madhyamam Mode", isOn: $useMadhyamam)
                    Toggle("Background Playback", isOn: $backgroundPlayback)
                } header: {
                    Text("Playback Settings")
                } footer: {
                    Text("Enable background playback to continue playing when the app is in the background")
                }
                
                Section {
                    HStack {
                        Image(systemName: "speaker.fill")
                        Slider(value: $volume, in: 0...1)
                        Image(systemName: "speaker.wave.3.fill")
                    }
                } header: {
                    Text("Volume")
                }
                
                Section {
                    Picker("Active Note Color", selection: $activeTheme) {
                        ForEach(ThemeColor.allCases, id: \.rawValue) { theme in
                            HStack {
                                Circle()
                                    .fill(themeColor(theme))
                                    .frame(width: 20, height: 20)
                                Text(theme.rawValue)
                            }
                            .tag(theme)
                        }
                    }
                    
                    Picker("Appearance Mode", selection: $colorSchemeMode) {
                        ForEach(ColorSchemeMode.allCases, id: \.rawValue) { mode in
                            HStack {
                                Image(systemName: mode == .light ? "sun.max.fill" : 
                                    mode == .dark ? "moon.fill" : "gear")
                                    .foregroundColor(mode == .light ? .orange : 
                                        mode == .dark ? .blue : .gray)
                                Text(mode.rawValue)
                            }
                            .tag(mode)
                        }
                    }
                } header: {
                    Text("Appearance")
                } footer: {
                    Text("Customize the app's appearance")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        // Save preferences when dismissing settings
                        UserDefaultsManager.shared.savePreferences(
                            theme: activeTheme,
                            colorScheme: colorSchemeMode,
                            useMadhyamam: useMadhyamam,
                            volume: volume,
                            backgroundPlayback: backgroundPlayback
                        )
                        dismiss()
                    }
                }
            }
        }
    }
}

struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

#Preview {
    ShrutiBoxView()
} 