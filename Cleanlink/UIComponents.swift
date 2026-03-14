import SwiftUI

struct PrimaryButton: View {
    let title: String
    let icon: String?
    let isSuccess: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            let impactMed = UIImpactFeedbackGenerator(style: .medium)
            impactMed.impactOccurred()
            action()
        }) {
            HStack {
                if isSuccess {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .bold))
                } else if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                }
                
                Text(title)
                    .font(Theme.Typography.headline)
            }
            .frame(maxWidth: .infinity, minHeight: 44)
            .padding(.vertical, 14)
            .background(isSuccess ? Theme.Colors.success : Theme.Colors.primary)
            .foregroundColor(.white)
            .cornerRadius(Theme.Radius.button)
            // Color transition animation
            .animation(.easeInOut(duration: 0.2), value: isSuccess)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct SecondaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            let impactMed = UIImpactFeedbackGenerator(style: .medium)
            impactMed.impactOccurred()
            action()
        }) {
            HStack {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                }
                Text(title)
                    .font(Theme.Typography.headline)
            }
            .frame(maxWidth: .infinity, minHeight: 44)
            .padding(.vertical, 14)
            .background(Color(UIColor.secondarySystemBackground))
            .foregroundColor(Theme.Colors.primary)
            .cornerRadius(Theme.Radius.button)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct LinkButton: View {
    let title: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.primary)
                .padding(.vertical, Theme.Spacing.micro)
        }
    }
}

struct InputCard: View {
    @Binding var text: String
    var showBadge: Bool = false
    var errorMessage: String? = nil
    var onClear: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.micro) {
            HStack {
                Text("Paste Links / Text")
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
                Spacer()
                if showBadge {
                    ClipboardBadge()
                }
            }
            
            HStack {
                if #available(iOS 16.0, *) {
                    TextField("https://instagram.com/...", text: $text, axis: .vertical)
                        .lineLimit(1...5)
                        .font(Theme.Typography.body)
                        .foregroundColor(Theme.Colors.textPrimary)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                } else {
                    TextField("https://instagram.com/...", text: $text)
                        .font(Theme.Typography.body)
                        .foregroundColor(Theme.Colors.textPrimary)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                
                if !text.isEmpty {
                    Button(action: onClear) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Theme.Colors.textSecondary)
                    }
                }
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            .cornerRadius(Theme.Radius.button)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.button)
                    .stroke(errorMessage != nil ? Theme.Colors.error.opacity(0.5) : Color(UIColor.quaternarySystemFill), lineWidth: 1)
            )
            
            if let error = errorMessage {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.triangle.fill")
                    Text(error)
                }
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.error)
                .padding(.top, 4)
                .padding(.leading, 4)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding()
        .surfaceBackground()
        .animation(.easeInOut(duration: 0.2), value: errorMessage)
        .cornerRadius(Theme.Radius.card)
    }
}

struct OutputCard: View {
    let cleanUrl: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.micro) {
            Text("Clean URL")
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.success)
            
            HStack {
                Text(cleanUrl)
                    .font(Theme.Typography.monospaced)
                    .foregroundColor(Theme.Colors.textPrimary)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            .cornerRadius(Theme.Radius.button)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.button)
                    .stroke(Theme.Colors.success.opacity(0.3), lineWidth: 1)
            )
            
            Text("Tracking parameters removed")
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.textSecondary)
        }
        .padding()
        .background(Theme.Colors.success.opacity(0.1))
        .cornerRadius(Theme.Radius.card)
        .transition(.asymmetric(insertion: .scale(scale: 0.95).combined(with: .opacity), removal: .opacity))
    }
}

struct ClipboardBadge: View {
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "doc.on.clipboard")
                .font(.system(size: 10))
            Text("Clipboard Auto-Detect")
                .font(.system(size: 11, weight: .semibold))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Theme.Colors.primary.opacity(0.1))
        .foregroundColor(Theme.Colors.primary)
        .cornerRadius(16)
        .transition(.opacity.combined(with: .move(edge: .top)))
    }
}
