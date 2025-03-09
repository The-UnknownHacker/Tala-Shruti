import SwiftUI
import AVFoundation

extension SoundAsset {
    var displayName: String {
        String(describing: self).replacingOccurrences(of: "Sharp", with: "#")
    }
}

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

private struct VolumeSliderView: View {
    @Binding var volume: Double
    let sliderMaxWidth: CGFloat
    @ObservedObject var tutorialManager: TutorialManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "speaker.fill")
                Slider(value: $volume, in: 0...1)
                Image(systemName: "speaker.wave.3.fill")
            }
            .padding(.horizontal)
            .frame(maxWidth: sliderMaxWidth)
            .frame(maxWidth: .infinity)
        }
        .background(
            GeometryReader { geometry in
                Color.clear.onAppear {
                    if tutorialManager.tutorialSteps[tutorialManager.currentStep].highlightType == .slider {
                        tutorialManager.updateHighlightFrame(geometry.frame(in: .global))
                    }
                }
            }
        )
    }
}

private struct ShrutiButtonGrid: View {
    let shrutis: [SoundAsset]
    let columns: [GridItem]
    let gridSpacing: CGFloat
    let horizontalPadding: CGFloat
    let gridMaxWidth: CGFloat
    let buttonSize: CGFloat
    let fontSize: CGFloat
    @Binding var selectedShruti: SoundAsset?
    @Binding var isPlaying: Bool
    var toggleShruti: (SoundAsset) -> Void
    let effectiveColorScheme: ColorScheme
    let activeTheme: ThemeColor
    let useMadhyamam: Bool
    @ObservedObject var tutorialManager: TutorialManager
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: gridSpacing) {
                ForEach(shrutis, id: \.rawValue) { shruti in
                    Button(action: { toggleShruti(shruti) }) {
                        ShrutiButtonContent(
                            shruti: shruti,
                            fontSize: fontSize,
                            buttonSize: buttonSize,
                            isSelected: selectedShruti == shruti,
                            isPlaying: isPlaying,
                            useMadhyamam: useMadhyamam,
                            effectiveColorScheme: effectiveColorScheme,
                            activeTheme: activeTheme,
                            tutorialManager: tutorialManager
                        )
                    }
                    .buttonStyle(PressableButtonStyle())
                }
            }
            .padding(.horizontal, horizontalPadding)
            .frame(maxWidth: gridMaxWidth)
            .frame(maxWidth: .infinity)
        }
    }
}

private struct ShrutiButtonContent: View {
    let shruti: SoundAsset
    let fontSize: CGFloat
    let buttonSize: CGFloat
    let isSelected: Bool
    let isPlaying: Bool
    let useMadhyamam: Bool
    let effectiveColorScheme: ColorScheme
    let activeTheme: ThemeColor
    @ObservedObject var tutorialManager: TutorialManager
    
    var body: some View {
        VStack(spacing: 8) {
            Text(shruti.displayName)
                .font(.system(size: fontSize, weight: .bold, design: .rounded))
                .foregroundColor(getTextColor())
            if isSelected && isPlaying {
                Text(useMadhyamam ? "Madhyamam" : "Playing")
                    .font(.caption)
                    .foregroundColor(getTextColor())
            }
        }
        .frame(minWidth: buttonSize, minHeight: buttonSize)
        .background(buttonBackground())
        .overlay(buttonBorder())
        .background(
            GeometryReader { geometry in
                Color.clear.onAppear {
                    if tutorialManager.tutorialSteps[tutorialManager.currentStep].highlightType == .button {
                        tutorialManager.updateHighlightFrame(geometry.frame(in: .global))
                    }
                }
            }
        )
    }
    
    private func getTextColor() -> Color {
        if isSelected && isPlaying {
            if activeTheme == .white {
                return effectiveColorScheme == .dark ? .black : .white
            }
            return .white
        }
        return effectiveColorScheme == .dark ? .white : .black
    }
    
    private func buttonBackground() -> some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(isSelected && isPlaying ? activeTheme.color : Color.clear)
            .shadow(
                color: (isSelected && isPlaying ? 
                    activeTheme.color.opacity(0.3) : 
                    Color.black.opacity(0.1)),
                radius: isSelected && isPlaying ? 10 : 5,
                y: 2
            )
    }
    
    private func buttonBorder() -> some View {
        RoundedRectangle(cornerRadius: 20)
            .strokeBorder(
                effectiveColorScheme == .dark ? 
                    .white.opacity(0.2) : 
                    .black.opacity(0.1),
                lineWidth: 1
            )
    }
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
    @State private var showInfo = false
    @StateObject private var tutorialManager = TutorialManager.shared
    @State private var currentPage = 0
    
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
    
    // Static properties for layout
    private static let iPadMinWidth: CGFloat = 150
    private static let iPadMaxWidth: CGFloat = 200
    private static let iPhoneMinWidth: CGFloat = 100
    private static let iPhoneMaxWidth: CGFloat = 150
    
    // Simplified columns property
    private var columns: [GridItem] {
        let isIPad = UIDevice.current.userInterfaceIdiom == .pad
        let minWidth = isIPad ? Self.iPadMinWidth : Self.iPhoneMinWidth
        let maxWidth = isIPad ? Self.iPadMaxWidth : Self.iPhoneMaxWidth
        
        let gridItem = GridItem(.adaptive(minimum: minWidth, maximum: maxWidth))
        return [gridItem, gridItem, gridItem]
    }
    
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
    
    // Add these helper properties
    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    private var stackSpacing: CGFloat {
        isIPad ? 48 : 32
    }
    
    private var sliderMaxWidth: CGFloat {
        isIPad ? 800 : 600
    }
    
    private var gridSpacing: CGFloat {
        isIPad ? 30 : 20
    }
    
    private var horizontalPadding: CGFloat {
        isIPad ? 40 : 20
    }
    
    private var gridMaxWidth: CGFloat {
        isIPad ? 1000 : 600
    }
    
    private var verticalPadding: CGFloat {
        isIPad ? 40 : 20
    }
    
    private var fontSize: CGFloat {
        isIPad ? 36 : 28
    }
    
    private var buttonSize: CGFloat {
        isIPad ? 120 : 90
    }
    
    var body: some View {
        NavigationView {
            TabView(selection: $currentPage) {
                ZStack {
                    backgroundColor.ignoresSafeArea()
                    
                    VStack(spacing: stackSpacing) {
                        VolumeSliderView(
                            volume: $volume,
                            sliderMaxWidth: sliderMaxWidth,
                            tutorialManager: tutorialManager
                        )
                        
                        ShrutiButtonGrid(
                            shrutis: shrutis,
                            columns: columns,
                            gridSpacing: gridSpacing,
                            horizontalPadding: horizontalPadding,
                            gridMaxWidth: gridMaxWidth,
                            buttonSize: buttonSize,
                            fontSize: fontSize,
                            selectedShruti: $selectedShruti,
                            isPlaying: $isPlaying,
                            toggleShruti: toggleShruti,
                            effectiveColorScheme: effectiveColorScheme,
                            activeTheme: activeTheme,
                            useMadhyamam: useMadhyamam,
                            tutorialManager: tutorialManager
                        )
                    }
                    .padding(.vertical, verticalPadding)
                    .frame(maxWidth: .infinity)
                    
                    if tutorialManager.showTutorial {
                        TutorialOverlay()
                    }
                }
                .tag(0)
                
                MetronomeView()
                    .tag(1)
                
                PercussionView()
                    .tag(2)
                
                TunerView()
                    .tag(3)
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            .padding(.bottom, -10)  // Negative padding to push dots to bottom
            .navigationTitle("Tala Shruti")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showInfo.toggle() }) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 20, weight: .regular))
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    // Only show settings when on shruti box page
                    if currentPage == 0 {
                        Button(action: { showSettings.toggle() }) {
                            Image(systemName: "gear")
                                .font(.system(size: 20, weight: .regular))
                        }
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
            .sheet(isPresented: $showInfo) {
                AboutView()
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
        .onAppear {
            // Configure audio for the main page
            print("ShrutiBoxView appeared - configuring audio for main page")
            AudioManager.shared.configureForMainPage()
            
            // Show tutorial on first launch
            if !UserDefaults.standard.bool(forKey: "hasSeenTutorial") {
                tutorialManager.startTutorial()
            }
        }
        .navigationViewStyle(.stack)
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
    @ObservedObject private var tutorialManager = TutorialManager.shared
    
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
                
                Section {
                    Button(action: {
                        dismiss()
                        tutorialManager.startTutorial()
                    }) {
                        HStack {
                            Image(systemName: "questionmark.circle")
                            Text("Start Tutorial")
                        }
                    }
                } header: {
                    Text("Help")
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