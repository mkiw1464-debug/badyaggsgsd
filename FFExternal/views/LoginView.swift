import SwiftUI

struct LoginView: View {
    @Environment(\.ffLanguage) private var lang
    @State private var keyInput: String = ""
    @State private var validating = false
    @State private var error: String? = nil
    let onSuccess: (LicenseInfo) -> Void

    var body: some View {
        ZStack {
            FFBackground()

            ScrollView {
                VStack(spacing: 28) {
                    Spacer(minLength: 70)

                    // Header
                    VStack(spacing: 10) {
                        Image(systemName: "scope")
                            .font(.system(size: 52, weight: .ultraLight))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [FFTheme.accent, FFTheme.accentAlt],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )

                        Text(lang.t("login_title"))
                            .font(FFTheme.titleFont)
                            .foregroundStyle(FFTheme.text)

                        Text(lang.t("login_subtitle"))
                            .font(FFTheme.subtitleFont)
                            .foregroundStyle(FFTheme.textSecondary)
                            .multilineTextAlignment(.center)
                    }

                    // Key Input Card
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(lang.t("key_label"))
                                .font(FFTheme.captionFont)
                                .foregroundStyle(FFTheme.textSecondary)
                                .textCase(.uppercase)
                                .tracking(1.2)

                            HStack(spacing: 10) {
                                Image(systemName: "key.fill")
                                    .font(.system(size: 14))
                                    .foregroundStyle(FFTheme.accent)

                                TextField(lang.t("key_placeholder"), text: $keyInput)
                                    .font(FFTheme.monoFont)
                                    .foregroundStyle(FFTheme.text)
                                    .autocapitalization(.allCharacters)
                                    .autocorrectionDisabled()
                                    .keyboardType(.asciiCapable)
                                    .tint(FFTheme.accent)
                            }
                            .padding(14)
                            .background(FFTheme.glass)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .strokeBorder(
                                        error != nil ? FFTheme.danger.opacity(0.7) :
                                            (!keyInput.isEmpty ? FFTheme.accent.opacity(0.5) : FFTheme.glassBorder),
                                        lineWidth: 1.2
                                    )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }

                        // Error message
                        if let error {
                            HStack(spacing: 6) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .foregroundStyle(FFTheme.danger)
                                    .font(.system(size: 13))
                                Text(error)
                                    .font(FFTheme.captionFont)
                                    .foregroundStyle(FFTheme.danger)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }

                        // Validate button
                        FFButton(
                            title: validating ? lang.t("validating") : lang.t("validate"),
                            icon: validating ? nil : "checkmark.shield.fill",
                            action: validate,
                            isLoading: validating,
                            isDisabled: keyInput.trimmingCharacters(in: .whitespaces).isEmpty
                        )
                    }
                    .glassCard()
                    .padding(.horizontal, 24)
                    .shimmerBorder()
                    .padding(.horizontal, 24)

                    // Device info footer
                    HStack(spacing: 16) {
                        InfoChip(icon: "iphone", label: DeviceID.deviceName)
                        InfoChip(icon: "cpu", label: "iOS \(AppInfo.osVersion)")
                    }
                    .padding(.horizontal, 24)

                    Spacer(minLength: 40)
                }
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.75), value: error)
        .onAppear {
            // Pre-fill stored key
            if let stored = LicenseService.storedKey() {
                keyInput = stored
            }
        }
    }

    private func validate() {
        let key = keyInput.trimmingCharacters(in: .whitespaces)
        guard !key.isEmpty else { return }
        error = nil
        validating = true

        Task {
            do {
                let info = try await LicenseService.validate(key: key)
                await MainActor.run {
                    validating = false
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                        onSuccess(info)
                    }
                }
            } catch {
                await MainActor.run {
                    validating = false
                    self.error = error.localizedDescription
                }
            }
        }
    }
}

private struct InfoChip: View {
    let icon: String
    let label: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 11))
                .foregroundStyle(FFTheme.accent)
            Text(label)
                .font(FFTheme.captionFont)
                .foregroundStyle(FFTheme.textSecondary)
                .lineLimit(1)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(FFTheme.glass)
        .overlay(
            Capsule()
                .strokeBorder(FFTheme.glassBorder, lineWidth: 1)
        )
        .clipShape(Capsule())
    }
}
