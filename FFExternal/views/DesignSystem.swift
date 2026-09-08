import SwiftUI

// MARK: - FF External Design System
// Theme: Dark grey background + blur glassmorphism

enum FFTheme {
    // MARK: Colors
    static let background       = Color(red: 0.08, green: 0.08, blue: 0.10)
    static let backgroundSecond = Color(red: 0.11, green: 0.11, blue: 0.13)
    static let glass            = Color.white.opacity(0.07)
    static let glassBorder      = Color.white.opacity(0.12)
    static let accent           = Color(red: 0.45, green: 0.85, blue: 1.00)   // cyan-ish
    static let accentAlt        = Color(red: 0.65, green: 0.45, blue: 1.00)   // purple-ish
    static let text             = Color.white
    static let textSecondary    = Color.white.opacity(0.55)
    static let success          = Color(red: 0.20, green: 0.90, blue: 0.50)
    static let danger           = Color(red: 1.00, green: 0.35, blue: 0.35)
    static let warn             = Color(red: 1.00, green: 0.75, blue: 0.20)

    // MARK: Typography
    static let titleFont   = Font.system(size: 28, weight: .bold,   design: .rounded)
    static let subtitleFont = Font.system(size: 14, weight: .regular, design: .rounded)
    static let bodyFont    = Font.system(size: 15, weight: .medium,  design: .rounded)
    static let captionFont = Font.system(size: 12, weight: .regular, design: .rounded)
    static let monoFont    = Font.system(size: 13, weight: .medium,  design: .monospaced)

    // MARK: Sizes
    static let cornerRadius: CGFloat = 18
    static let cardPadding: CGFloat  = 18
    static let glassBlur: CGFloat    = 24
}

// MARK: - Glass Card Modifier

struct GlassCard: ViewModifier {
    var padding: CGFloat = FFTheme.cardPadding
    var cornerRadius: CGFloat = FFTheme.cornerRadius

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                ZStack {
                    // Blur layer
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .opacity(0.7)
                    // Tint overlay
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(FFTheme.glass)
                    // Border
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .strokeBorder(FFTheme.glassBorder, lineWidth: 1)
                }
            )
    }
}

extension View {
    func glassCard(padding: CGFloat = FFTheme.cardPadding,
                   cornerRadius: CGFloat = FFTheme.cornerRadius) -> some View {
        modifier(GlassCard(padding: padding, cornerRadius: cornerRadius))
    }
}

// MARK: - Gradient Background

struct FFBackground: View {
    var body: some View {
        ZStack {
            FFTheme.background.ignoresSafeArea()

            // Subtle radial glow top-center
            RadialGradient(
                colors: [
                    FFTheme.accent.opacity(0.08),
                    Color.clear
                ],
                center: .top,
                startRadius: 0,
                endRadius: 400
            )
            .ignoresSafeArea()

            // Bottom glow
            RadialGradient(
                colors: [
                    FFTheme.accentAlt.opacity(0.06),
                    Color.clear
                ],
                center: .bottom,
                startRadius: 0,
                endRadius: 350
            )
            .ignoresSafeArea()
        }
    }
}

// MARK: - Animated shimmer border

struct ShimmerBorder: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: FFTheme.cornerRadius, style: .continuous)
                    .strokeBorder(
                        AngularGradient(
                            colors: [
                                FFTheme.accent.opacity(0.6),
                                FFTheme.accentAlt.opacity(0.4),
                                FFTheme.accent.opacity(0.2),
                                FFTheme.accentAlt.opacity(0.5),
                                FFTheme.accent.opacity(0.6),
                            ],
                            center: .center,
                            angle: .degrees(phase * 360)
                        ),
                        lineWidth: 1.2
                    )
                    .animation(
                        .linear(duration: 4).repeatForever(autoreverses: false),
                        value: phase
                    )
                    .onAppear { phase = 1 }
            )
    }
}

extension View {
    func shimmerBorder() -> some View { modifier(ShimmerBorder()) }
}

// MARK: - FF Accent Button

struct FFButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    var isLoading: Bool = false
    var isDisabled: Bool = false
    var style: ButtonStyle = .primary

    enum ButtonStyle { case primary, secondary, danger }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .tint(FFTheme.background)
                        .scaleEffect(0.85)
                } else if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .semibold))
                }
                Text(title)
                    .font(FFTheme.bodyFont)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(buttonBackground)
            .foregroundStyle(buttonForeground)
            .clipShape(RoundedRectangle(cornerRadius: FFTheme.cornerRadius - 4, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: FFTheme.cornerRadius - 4, style: .continuous)
                    .strokeBorder(buttonBorder, lineWidth: 1)
            )
            .opacity(isDisabled ? 0.45 : 1.0)
        }
        .disabled(isDisabled || isLoading)
        .buttonStyle(.plain)
    }

    private var buttonBackground: some ShapeStyle {
        switch style {
        case .primary:
            return AnyShapeStyle(
                LinearGradient(
                    colors: [FFTheme.accent, FFTheme.accentAlt],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
        case .secondary:
            return AnyShapeStyle(FFTheme.glass)
        case .danger:
            return AnyShapeStyle(FFTheme.danger.opacity(0.25))
        }
    }

    private var buttonForeground: Color {
        switch style {
        case .primary:   return FFTheme.background
        case .secondary: return FFTheme.text
        case .danger:    return FFTheme.danger
        }
    }

    private var buttonBorder: Color {
        switch style {
        case .primary:   return Color.clear
        case .secondary: return FFTheme.glassBorder
        case .danger:    return FFTheme.danger.opacity(0.5)
        }
    }
}
