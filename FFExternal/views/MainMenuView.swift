import SwiftUI

// MARK: - App State

class FFAppState: ObservableObject {
    @Published var exploitStatus: ExploitStatus = .notStarted
    @Published var exploitRunning = false
    @Published var ffInjected   = false   // Free Fire injected
    @Published var ffMaxInjected = false  // FF Max injected

    private var autoRunDone = false

    var isSupported: Bool {
        if case .unsupported = exploitStatus { return false }
        return true
    }

    func boot() {
        let v = AppInfo.versionTuple
        let supported = ExploitSupportPolicy.isSupported(
            major: v.major, minor: v.minor, patch: v.patch, build: AppInfo.osBuild
        )
        if !supported {
            exploitStatus = .unsupported("iOS \(AppInfo.osVersion)")
            return
        }
        if KernelExploit.requiresSandboxEscape && KernelExploit.hasSandboxAccess() {
            exploitStatus = .success(method: "kexploit")
            return
        }
        if !autoRunDone { autoRunDone = true; runExploit() }
    }

    func runExploit() {
        guard !exploitRunning, !exploitStatus.isSuccess else { return }
        exploitRunning = true
        exploitStatus = .notStarted
        DispatchQueue.global(qos: .userInitiated).async {
            let ok = KernelExploit.run()
            DispatchQueue.main.async {
                self.exploitRunning = false
                self.exploitStatus = ok
                    ? .success(method: "kexploit")
                    : .failed(method: "kexploit", code: -1)
            }
        }
    }

    func syncInjectedState() {
        ffInjected    = LicenseService.storedKey() != nil &&
            (ContainerStore.resolveAppContainerPath(bundleID: FFGame.freeFire.rawValue) != nil) &&
            FFCheatService.hasBackup(bundleID: FFGame.freeFire.rawValue)
        ffMaxInjected = LicenseService.storedKey() != nil &&
            (ContainerStore.resolveAppContainerPath(bundleID: FFGame.freefireMax.rawValue) != nil) &&
            FFCheatService.hasBackup(bundleID: FFGame.freefireMax.rawValue)
    }
}

// MARK: - Main Menu

struct MainMenuView: View {
    @Environment(\.ffLanguage) private var lang
    @StateObject private var state = FFAppState()
    @State private var selectedTab: Int = 0

    let licenseInfo: LicenseInfo

    var body: some View {
        ZStack {
            FFBackground()

            VStack(spacing: 0) {
                // Top bar
                topBar

                // Tab selector
                gameTabBar

                // Content
                TabView(selection: $selectedTab) {
                    GameMenuView(
                        game: .freeFire,
                        injected: $state.ffInjected,
                        exploitReady: state.exploitStatus.isSuccess
                    )
                    .tag(0)

                    GameMenuView(
                        game: .freefireMax,
                        injected: $state.ffMaxInjected,
                        exploitReady: state.exploitStatus.isSuccess
                    )
                    .tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.spring(response: 0.35, dampingFraction: 0.85), value: selectedTab)

                // Telegram footer
                telegramBanner
            }
        }
        .onAppear {
            state.boot()
            state.syncInjectedState()
        }
    }

    // MARK: Sub-views

    private var topBar: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 2) {
                Text("FF External")
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundStyle(FFTheme.text)

                // Key info
                HStack(spacing: 8) {
                    Text(LicenseService.maskedKey(licenseInfo.key))
                        .font(FFTheme.monoFont)
                        .foregroundStyle(FFTheme.textSecondary)

                    Circle()
                        .fill(FFTheme.glassBorder)
                        .frame(width: 3, height: 3)

                    Text(licenseInfo.expiresAt)
                        .font(FFTheme.captionFont)
                        .foregroundStyle(FFTheme.textSecondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            // Exploit status pill
            exploitPill
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }

    private var exploitPill: some View {
        HStack(spacing: 5) {
            if state.exploitRunning {
                ProgressView()
                    .controlSize(.mini)
                    .tint(FFTheme.warn)
                Text("Loading")
                    .font(FFTheme.captionFont)
                    .foregroundStyle(FFTheme.warn)
            } else {
                Circle()
                    .fill(state.exploitStatus.isSuccess ? FFTheme.success : FFTheme.danger)
                    .frame(width: 7, height: 7)
                Text(state.exploitStatus.isSuccess ? "Active" : "Inactive")
                    .font(FFTheme.captionFont)
                    .foregroundStyle(state.exploitStatus.isSuccess ? FFTheme.success : FFTheme.danger)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(FFTheme.glass)
        .clipShape(Capsule())
        .overlay(Capsule().strokeBorder(FFTheme.glassBorder, lineWidth: 1))
    }

    private var gameTabBar: some View {
        HStack(spacing: 0) {
            ForEach([FFGame.freeFire, FFGame.freefireMax].indices, id: \.self) { i in
                let game: FFGame = i == 0 ? .freeFire : .freefireMax
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                        selectedTab = i
                    }
                } label: {
                    VStack(spacing: 4) {
                        Text(game.displayName)
                            .font(.system(size: 13, weight: selectedTab == i ? .bold : .regular, design: .rounded))
                            .foregroundStyle(selectedTab == i ? FFTheme.accent : FFTheme.textSecondary)

                        // Active indicator
                        Capsule()
                            .fill(selectedTab == i ? FFTheme.accent : Color.clear)
                            .frame(height: 2)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                }
                .buttonStyle(.plain)
            }
        }
        .background(FFTheme.glass)
        .overlay(
            Rectangle()
                .fill(FFTheme.glassBorder)
                .frame(height: 1),
            alignment: .bottom
        )
    }

    private var telegramBanner: some View {
        Button {
            if let url = URL(string: "https://t.me/ffexternal") {
                UIApplication.shared.open(url)
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 13))
                    .foregroundStyle(FFTheme.accent)
                Text(lang.t("telegram"))
                    .font(FFTheme.captionFont)
                    .foregroundStyle(FFTheme.textSecondary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 11))
                    .foregroundStyle(FFTheme.textSecondary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(FFTheme.glass)
            .overlay(
                Rectangle()
                    .fill(FFTheme.glassBorder)
                    .frame(height: 1),
                alignment: .top
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Game Menu View

struct GameMenuView: View {
    @Environment(\.ffLanguage) private var lang
    let game: FFGame
    @Binding var injected: Bool
    let exploitReady: Bool

    @State private var selectedFeature: FFFeature = .aimBody
    @State private var injecting = false
    @State private var showTerminal = false
    @State private var terminalLines: [String] = []
    @State private var showSuccess = false
    @State private var showRestoreSuccess = false
    @State private var errorMessage: String? = nil
    @State private var availability: [FFFeature: Bool] = [:]
    @State private var checkingAvailability = true

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                // Feature grid
                featureGrid
                    .padding(.horizontal, 16)

                // Tutorial hint
                hintCard
                    .padding(.horizontal, 16)

                // Action buttons
                actionButtons
                    .padding(.horizontal, 16)

                // Error
                if let err = errorMessage {
                    Text(err)
                        .font(FFTheme.captionFont)
                        .foregroundStyle(FFTheme.danger)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .transition(.opacity)
                }

                Spacer(minLength: 24)
            }
            .padding(.top, 16)
        }
        .overlay(
            Group {
                if showTerminal { terminalOverlay }
                if showSuccess  { successOverlay(text: lang.t("inject_success"), icon: "checkmark.seal.fill", color: FFTheme.success) }
                if showRestoreSuccess { successOverlay(text: lang.t("restore_success"), icon: "arrow.uturn.backward.circle.fill", color: FFTheme.warn) }
            }
        )
        .animation(.easeInOut(duration: 0.25), value: errorMessage)
        .task { await checkAvailability() }
    }

    // MARK: Feature Grid

    private var featureGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
            ForEach(FFFeature.allCases, id: \.self) { feature in
                FeatureCard(
                    feature: feature,
                    isSelected: selectedFeature == feature,
                    available: availability[feature] ?? true,
                    loading: checkingAvailability
                ) {
                    if availability[feature] ?? true {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                            selectedFeature = feature
                        }
                    }
                }
            }
        }
    }

    // MARK: Hint Card

    private var hintCard: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "info.circle.fill")
                .foregroundStyle(FFTheme.accent)
                .font(.system(size: 14))
                .padding(.top, 1)

            Text(lang.t("inject_hint"))
                .font(FFTheme.captionFont)
                .foregroundStyle(FFTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .glassCard(padding: 12)
    }

    // MARK: Action Buttons

    private var actionButtons: some View {
        VStack(spacing: 10) {
            if !injected {
                FFButton(
                    title: lang.t("inject"),
                    icon: "bolt.fill",
                    action: doInject,
                    isLoading: injecting,
                    isDisabled: !exploitReady || injecting || !(availability[selectedFeature] ?? true)
                )
            } else {
                // Already injected — show restore only
                FFButton(
                    title: lang.t("restore"),
                    icon: "arrow.uturn.backward.circle.fill",
                    action: doRestore,
                    isDisabled: injecting,
                    style: .secondary
                )
            }
        }
    }

    // MARK: Terminal Overlay

    private var terminalOverlay: some View {
        ZStack {
            Color.black.opacity(0.75).ignoresSafeArea()
                .blur(radius: 2)

            VStack(alignment: .leading, spacing: 0) {
                // Terminal header
                HStack {
                    Circle().fill(Color(red: 1, green: 0.37, blue: 0.33)).frame(width: 10, height: 10)
                    Circle().fill(Color(red: 1, green: 0.73, blue: 0.18)).frame(width: 10, height: 10)
                    Circle().fill(Color(red: 0.15, green: 0.78, blue: 0.40)).frame(width: 10, height: 10)
                    Spacer()
                    Text("FF External — Inject")
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.5))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.06))

                // Terminal body
                ScrollView {
                    VStack(alignment: .leading, spacing: 3) {
                        ForEach(terminalLines.indices, id: \.self) { i in
                            Text(terminalLines[i])
                                .font(.system(size: 12, weight: .regular, design: .monospaced))
                                .foregroundStyle(lineColor(terminalLines[i]))
                        }
                        // Blinking cursor
                        Text("█")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundStyle(FFTheme.accent)
                            .opacity(0.8)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(height: 180)
                .background(Color.black.opacity(0.85))
            }
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(FFTheme.glassBorder, lineWidth: 1)
            )
            .padding(.horizontal, 28)
        }
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
    }

    private func lineColor(_ line: String) -> Color {
        if line.contains("✓") || line.contains("OK") || line.contains("success") { return FFTheme.success }
        if line.contains("✗") || line.contains("error") || line.contains("FAIL")  { return FFTheme.danger }
        if line.contains("→") || line.contains("Resolving") || line.contains("Downloading") { return FFTheme.accent }
        return .white.opacity(0.75)
    }

    // MARK: Success Overlay

    private func successOverlay(text: String, icon: String, color: Color) -> some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 44))
                .foregroundStyle(color)

            Text(text)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundStyle(FFTheme.text)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(FFTheme.background.opacity(0.88).ignoresSafeArea())
        .transition(.opacity)
    }

    // MARK: Actions

    private func doInject() {
        let feature = selectedFeature
        terminalLines = []
        errorMessage = nil

        withAnimation { showTerminal = true }

        func line(_ s: String) {
            DispatchQueue.main.async {
                terminalLines.append(s)
            }
        }

        Task {
            line("→ Resolving container: \(game.rawValue)")
            try? await Task.sleep(for: .milliseconds(350))
            line("→ Checking sandbox access...")
            try? await Task.sleep(for: .milliseconds(350))
            line("→ Downloading \(feature.displayName)...")
            try? await Task.sleep(for: .milliseconds(500))

            do {
                try await FFCheatService.inject(game: game, feature: feature)
                line("→ Replacing gameassetbundles/cache_res...")
                try? await Task.sleep(for: .milliseconds(400))
                line("✓ Inject success — \(feature.displayName)")

                try? await Task.sleep(for: .milliseconds(600))
                await MainActor.run {
                    withAnimation { showTerminal = false }
                    injected = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        withAnimation { showSuccess = true }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            withAnimation { showSuccess = false }
                        }
                    }
                }
            } catch {
                line("✗ Error: \(error.localizedDescription)")
                try? await Task.sleep(for: .milliseconds(1500))
                await MainActor.run {
                    withAnimation { showTerminal = false }
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func doRestore() {
        errorMessage = nil
        injecting = true
        Task {
            do {
                try FFCheatService.restore(game: game)
                await MainActor.run {
                    injecting = false
                    injected = false
                    withAnimation { showRestoreSuccess = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                        withAnimation { showRestoreSuccess = false }
                    }
                }
            } catch {
                await MainActor.run {
                    injecting = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func checkAvailability() async {
        checkingAvailability = true
        var result: [FFFeature: Bool] = [:]
        await withTaskGroup(of: (FFFeature, Bool).self) { group in
            for feature in FFFeature.allCases {
                group.addTask {
                    let ok = await FFCheatManifest.checkAvailability(game: self.game, feature: feature)
                    return (feature, ok)
                }
            }
            for await (feature, ok) in group {
                result[feature] = ok
            }
        }
        await MainActor.run {
            availability = result
            checkingAvailability = false
        }
    }
}

// MARK: - Feature Card

private struct FeatureCard: View {
    let feature: FFFeature
    let isSelected: Bool
    let available: Bool
    let loading: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(isSelected ? FFTheme.accent.opacity(0.2) : FFTheme.glass)
                        .frame(width: 40, height: 40)

                    if loading {
                        ProgressView()
                            .controlSize(.mini)
                            .tint(FFTheme.textSecondary)
                    } else {
                        Image(systemName: featureIcon)
                            .font(.system(size: 17, weight: .medium))
                            .foregroundStyle(
                                !available ? FFTheme.textSecondary :
                                isSelected ? FFTheme.accent : FFTheme.text
                            )
                    }
                }

                Text(feature.displayName)
                    .font(.system(size: 11, weight: isSelected ? .bold : .regular, design: .rounded))
                    .foregroundStyle(
                        !available ? FFTheme.textSecondary :
                        isSelected ? FFTheme.accent : FFTheme.text
                    )
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                if !available && !loading {
                    Text("N/A")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(FFTheme.danger)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isSelected ? FFTheme.accent.opacity(0.12) : FFTheme.glass)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(
                                isSelected ? FFTheme.accent.opacity(0.6) : FFTheme.glassBorder,
                                lineWidth: isSelected ? 1.5 : 1
                            )
                    )
            )
            .scaleEffect(isSelected ? 1.03 : 1.0)
            .opacity((!available && !loading) ? 0.5 : 1.0)
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isSelected)
    }

    private var featureIcon: String {
        switch feature {
        case .aimBody:     return "figure.stand"
        case .aimNeck:     return "scope"
        case .aimDrag:     return "cursorarrow.motionlines"
        case .magicBullet: return "burst.fill"
        case .antena:      return "antenna.radiowaves.left.and.right"
        case .hologram:    return "waveform"
        }
    }
}
