import SwiftUI

@main
struct FFExternalApp: App {
    @AppStorage(FFLanguage.storageKey) private var storedLang = FFLanguage.english.rawValue

    init() {
        setupLogCapture()
        log("FFExternal: launching — iOS \(AppInfo.osVersion) (\(AppInfo.osBuild)) \(AppInfo.displayMachineName)")
    }

    private var language: FFLanguage {
        FFLanguage(rawValue: storedLang) ?? .english
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.ffLanguage, language)
                .preferredColorScheme(.dark)
        }
    }
}

// MARK: - Root Navigation

private enum AppScreen {
    case languagePicker
    case login
    case menu(LicenseInfo)
}

struct RootView: View {
    @AppStorage(FFLanguage.storageKey) private var storedLang = FFLanguage.english.rawValue
    @State private var screen: AppScreen = .languagePicker

    private var language: FFLanguage {
        FFLanguage(rawValue: storedLang) ?? .english
    }

    var body: some View {
        Group {
            switch screen {
            case .languagePicker:
                LanguagePickerView {
                    withAnimation(.spring(response: 0.42, dampingFraction: 0.85)) {
                        screen = .login
                    }
                }
                .transition(.asymmetric(
                    insertion: .opacity,
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))

            case .login:
                LoginView { info in
                    withAnimation(.spring(response: 0.42, dampingFraction: 0.85)) {
                        screen = .menu(info)
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))

            case .menu(let info):
                MainMenuView(licenseInfo: info)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .opacity
                    ))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.88), value: screenID)
        .environment(\.ffLanguage, language)
        .onAppear {
            // If we have a stored key, skip language picker and go directly to login
            if LicenseService.storedKey() != nil {
                screen = .login
            }
        }
    }

    private var screenID: Int {
        switch screen {
        case .languagePicker: return 0
        case .login:          return 1
        case .menu:           return 2
        }
    }
}
