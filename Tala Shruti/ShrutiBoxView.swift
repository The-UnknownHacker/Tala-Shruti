import SwiftUI
import AVFoundation

extension SoundAsset {
    var displayName: String {
        String(describing: self).replacingOccurrences(of: "Sharp", with: "#")
    }
    
    var octave: Int {
        switch self {
        case .C, .CSharp, .D, .DSharp, .E, .F: return 4
        case .FSharp, .G, .GSharp, .A, .ASharp, .B: return 5
        }
    }
    
    var noteValue: String {
        switch self {
        case .C: return "0"
        case .CSharp: return "0.5"
        case .D: return "1"
        case .DSharp: return "1.5"
        case .E: return "2"
        case .F: return "3"
        case .FSharp: return "3.5"
        case .G: return "5"
        case .GSharp: return "5.5"
        case .A: return "6"
        case .ASharp: return "6.5"
        case .B: return "7"
        }
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
    let shrutiMode: ShrutiMode
    
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
                            shrutiMode: shrutiMode,
                            effectiveColorScheme: effectiveColorScheme,
                            activeTheme: activeTheme
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
    let shrutiMode: ShrutiMode
    let effectiveColorScheme: ColorScheme
    let activeTheme: ThemeColor
    
    var body: some View {
        VStack(spacing: 8) {
            Text(shruti.displayName)
                .font(.system(size: fontSize, weight: .bold, design: .rounded))
                .foregroundColor(getTextColor())
            if isSelected && isPlaying {
                Text(shrutiMode.shortName)
                    .font(.caption)
                    .foregroundColor(getTextColor())
            }
        }
        .frame(minWidth: buttonSize, minHeight: buttonSize)
        .background(buttonBackground())
        .overlay(buttonBorder())
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
    @State private var shrutiMode: ShrutiMode
    @State private var audioPlayer: AVAudioPlayer?
    @State private var selectedShruti: SoundAsset?
    @State private var showSettings = false
    @State private var activeTheme: ThemeColor
    @State private var colorSchemeMode: ColorSchemeMode
    @Environment(\.colorScheme) var systemColorScheme
    @State private var volume: Double
    @State private var backgroundPlayback: Bool
    @State private var showInfo = false
    @State private var currentPage = 0
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0
    
    init() {
        let defaults = UserDefaultsManager.shared
        _activeTheme = State(initialValue: defaults.loadTheme())
        _colorSchemeMode = State(initialValue: defaults.loadColorScheme())
        _shrutiMode = State(initialValue: defaults.loadShrutiMode())
        _volume = State(initialValue: defaults.loadVolume())
        _backgroundPlayback = State(initialValue: defaults.loadBackgroundPlayback())
    }
    
    let shrutis: [SoundAsset] = [
        .C, .CSharp, .D, .DSharp, .E, .F,
        .FSharp, .G, .GSharp, .A, .ASharp, .B
    ]
    
    private static let iPadMinWidth: CGFloat = 150
    private static let iPadMaxWidth: CGFloat = 200
    private static let iPhoneMinWidth: CGFloat = 100
    private static let iPhoneMaxWidth: CGFloat = 150
    
    private var columns: [GridItem] {
        let isIPad = UIDevice.current.userInterfaceIdiom == .pad
        let minWidth = isIPad ? Self.iPadMinWidth : Self.iPhoneMinWidth
        let maxWidth = isIPad ? Self.iPadMaxWidth : Self.iPhoneMaxWidth
        
        let gridItem = GridItem(.adaptive(minimum: minWidth, maximum: maxWidth))
        return [gridItem, gridItem, gridItem]
    }
    
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
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(.systemBackground),
                            Color(.secondarySystemBackground)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                    
                    VStack(spacing: 30) {
                        ZStack {
                            Circle()
                                .fill(Color(.secondarySystemBackground))
                                .shadow(radius: 10)
                            
                            ForEach(Array(shrutis.enumerated()), id: \.element) { index, shruti in
                                let angle = Double(index) * (360.0 / Double(shrutis.count))
                                ShrutiButton(
                                    shruti: shruti,
                                    isSelected: selectedShruti == shruti,
                                    isPlaying: isPlaying,
                                    shrutiMode: shrutiMode,
                                    angle: angle,
                                    activeTheme: activeTheme
                                )
                                .offset(y: -150)
                                .rotationEffect(.degrees(angle))
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                        toggleShruti(shruti)
                                    }
                                }
                            }
                            
                            VStack(spacing: 8) {
                                if let selected = selectedShruti {
                                    Text(selected.displayName)
                                        .font(.system(size: 48, weight: .bold, design: .rounded))
                                    Text(selected.noteValue)
                                        .font(.title2)
                                        .foregroundColor(.secondary)
                                    Text(shrutiMode.shortName)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                } else {
                                    Text("Tap a note")
                                        .font(.title)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .frame(width: 120, height: 120)
                            .background(
                                Circle()
                                    .fill(Color(.systemBackground))
                                    .shadow(radius: 5)
                            )
                        }
                        .frame(width: 400, height: 400)
                        .rotationEffect(.degrees(rotation))
                        .scaleEffect(scale)
                        .gesture(
                            RotationGesture()
                                .onChanged { value in
                                    rotation = value.degrees
                                }
                                .onEnded { _ in
                                    withAnimation(.spring()) {
                                        rotation = 0
                                    }
                                }
                        )
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    scale = value
                                }
                                .onEnded { _ in
                                    withAnimation(.spring()) {
                                        scale = 1.0
                                    }
                                }
                        )
                        
                        VStack(spacing: 20) {
                            HStack(spacing: 12) {
                                Image(systemName: "speaker.fill")
                                    .foregroundColor(.secondary)
                                Slider(value: $volume, in: 0...1)
                                    .tint(.accentColor)
                                Image(systemName: "speaker.wave.3.fill")
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal)
                            
                            HStack(spacing: 12) {
                                ForEach(ShrutiMode.allCases, id: \.self) { mode in
                                    Button(action: { 
                                        shrutiMode = mode
                                        if isPlaying, let currentShruti = selectedShruti {
                                            stopPlaying()
                                            playShruti(currentShruti)
                                        }
                                    }) {
                                        Text(mode.shortName)
                                            .font(.system(.body, design: .rounded))
                                            .fontWeight(.semibold)
                                            .frame(minWidth: 60)
                                    }
                                    .buttonStyle(.bordered)
                                    .tint(shrutiMode == mode ? .accentColor : .gray)
                                }
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(.secondarySystemBackground))
                                .shadow(radius: 5)
                        )
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
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
            .navigationTitle("Tala Shruti")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showInfo.toggle() }) {
                        Image(systemName: "info.circle")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if currentPage == 0 {
                        Button(action: { showSettings.toggle() }) {
                            Image(systemName: "gear")
                        }
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(
                    shrutiMode: $shrutiMode,
                    volume: $volume,
                    backgroundPlayback: $backgroundPlayback,
                    activeTheme: $activeTheme,
                    colorSchemeMode: $colorSchemeMode
                )
            }
            .sheet(isPresented: $showInfo) {
                AboutView()
            }
        }
        .onChange(of: activeTheme) { _ in savePreferences() }
        .onChange(of: colorSchemeMode) { _ in savePreferences() }
        .onChange(of: shrutiMode) { _ in savePreferences() }
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
            AudioManager.shared.configureForMainPage()
        }
        .navigationViewStyle(.stack)
    }
    
    private func toggleShruti(_ note: SoundAsset) {
        if selectedShruti == note && isPlaying {
            stopPlaying()
            return
        }
        playShruti(note)
    }
    
    private func playShruti(_ note: SoundAsset) {
        stopPlaying()
        
        let filename = note.fileName(mode: shrutiMode)
        
        if let url = Bundle.main.url(forResource: filename, withExtension: "wav") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.prepareToPlay()
                audioPlayer?.numberOfLoops = -1
                audioPlayer?.volume = Float(volume)
                
                if audioPlayer?.play() == true {
                    isPlaying = true
                    selectedShruti = note
                }
            } catch {
                print("Could not create audio player: \(error)")
            }
        } else {
            print("Could not find audio file: \(filename).wav")
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
            shrutiMode: shrutiMode,
            volume: volume,
            backgroundPlayback: backgroundPlayback
        )
    }
}

struct ShrutiButton: View {
    let shruti: SoundAsset
    let isSelected: Bool
    let isPlaying: Bool
    let shrutiMode: ShrutiMode
    let angle: Double
    let activeTheme: ThemeColor
    
    var body: some View {
        VStack(spacing: 4) {
            Text(shruti.displayName)
                .font(.system(.body, design: .rounded))
                .fontWeight(.bold)
            
            if isSelected && isPlaying {
                Text(shrutiMode.shortName)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(activeTheme == .white ? .black : .white)
            }
        }
        .frame(width: 60, height: 60)
        .background(
            Circle()
                .fill(isSelected && isPlaying ? activeTheme.color : Color(.systemBackground))
                .shadow(radius: 3)
        )
        .overlay(
            Circle()
                .strokeBorder(isSelected && isPlaying ? activeTheme.color : Color.secondary.opacity(0.3), lineWidth: 1)
        )
        .foregroundColor(isSelected && isPlaying ? 
            (activeTheme == .white ? .black : .white) : 
            .primary)
        .rotationEffect(.degrees(-angle))
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @Binding var shrutiMode: ShrutiMode
    @Binding var volume: Double
    @Binding var backgroundPlayback: Bool
    @Binding var activeTheme: ThemeColor
    @Binding var colorSchemeMode: ColorSchemeMode
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Picker("Shruti Mode", selection: $shrutiMode) {
                        ForEach(ShrutiMode.allCases, id: \.self) { mode in
                            Text(mode.displayName).tag(mode)
                        }
                    }
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
                    Picker("Theme", selection: $activeTheme) {
                        ForEach(ThemeColor.allCases, id: \.rawValue) { theme in
                            Text(theme.rawValue).tag(theme)
                        }
                    }
                    
                    Picker("Appearance", selection: $colorSchemeMode) {
                        ForEach(ColorSchemeMode.allCases, id: \.rawValue) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                } header: {
                    Text("Appearance")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        UserDefaultsManager.shared.savePreferences(
                            theme: activeTheme,
                            colorScheme: colorSchemeMode,
                            shrutiMode: shrutiMode,
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