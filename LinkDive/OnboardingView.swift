import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var viewModel: LinkDiveViewModel
    @State private var currentPage = 0
    let totalPages = 3
    
    var body: some View {
        VStack(spacing: 0) {
            // Header Navigation
            HStack {
                if currentPage > 0 {
                    Button(action: {
                        withAnimation {
                            currentPage -= 1
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(Color(hex: "0F172A"))
                    }
                }
                Spacer()
                Button("Skip") {
                    finishOnboarding()
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(hex: "94A3B8"))
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 16)
            
            // TabView for Pages
            TabView(selection: $currentPage) {
                OnboardingPage1()
                    .tag(0)
                
                OnboardingPage2()
                    .tag(1)
                
                OnboardingPage3()
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            // Footer Controls
            VStack(spacing: 24) {
                // Pagination Dots
                HStack(spacing: 8) {
                    ForEach(0..<totalPages, id: \.self) { index in
                        Circle()
                            .fill(currentPage == index ? Theme.Colors.primary : Color(hex: "E2E8F0"))
                            .frame(width: currentPage == index ? 8 : 6, height: currentPage == index ? 8 : 6)
                    }
                }
                
                // CTA Button
                Button(action: {
                    if currentPage < totalPages - 1 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        finishOnboarding()
                    }
                }) {
                    Text(currentPage == 2 ? "Show Me the Fix" : "Continue")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Theme.Colors.primary)
                        .cornerRadius(Theme.Radius.button)
                        .shadow(color: Theme.Colors.primary.opacity(0.2), radius: 10, y: 5)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .background(Color.white.ignoresSafeArea())
    }
    
    private func finishOnboarding() {
        let impactMed = UIImpactFeedbackGenerator(style: .medium)
        impactMed.impactOccurred()
        withAnimation(.spring()) {
            viewModel.hasSeenOnboarding = true
        }
    }
}

// MARK: - Page 1: Hook
struct OnboardingPage1: View {
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Privacy Warning Badge
            HStack(spacing: 8) {
                Image(systemName: "eye.slash.circle.fill")
                    .foregroundColor(Theme.Colors.error)
                Text("Your identity is hidden in every link")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Theme.Colors.error)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Theme.Colors.error.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Theme.Colors.error.opacity(0.2), lineWidth: 1)
            )
            .cornerRadius(16)
            .padding(.bottom, 32)
            
            // Platform Grid
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    PlatformIcon(bgColor: "E1306C", text: "IG")
                    PlatformIcon(bgColor: "010101", text: "TT")
                    PlatformIcon(bgColor: "1DA1F2", text: "X")
                }
                HStack(spacing: 16) {
                    PlatformIcon(bgColor: "FF0000", text: "YT")
                    PlatformIcon(bgColor: "1877F2", text: "FB")
                    PlatformIcon(bgColor: "0A66C2", text: "IN")
                }
            }
            .padding(.bottom, 48)
            
            // Copy Text
            VStack(spacing: 16) {
                Text("Every link you share exposes you.")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(Color(hex: "0F172A"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                
                Text("When you copy a link from Instagram, TikTok, or YouTube, those platforms secretly attach a tracking code that reveals your account to anyone who opens it.")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(Color(hex: "64748B"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
                    .lineSpacing(4)
            }
            
            Spacer()
        }
        .padding(.horizontal, 24)
    }
}

struct PlatformIcon: View {
    let bgColor: String
    let text: String
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: bgColor))
                .frame(width: 64, height: 64)
                .overlay(
                    Text(text)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                )
            
            Circle()
                .fill(Theme.Colors.error)
                .frame(width: 12, height: 12)
                .overlay(
                    Circle().stroke(Color.white, lineWidth: 2)
                )
                .offset(x: 4, y: -4)
        }
    }
}

// MARK: - Page 2: Proof
struct OnboardingPage2: View {
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            VStack(spacing: 24) {
                // Before Card
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("BEFORE")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Theme.Colors.error)
                        Spacer()
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(Theme.Colors.error)
                    }
                    
                    Text("instagram.com/reel/abc.../?igsh=tracking_code")
                        .font(.system(size: 12, weight: .regular, design: .monospaced))
                        .foregroundColor(Theme.Colors.error)
                        .padding(12)
                        .background(Theme.Colors.error.opacity(0.05))
                        .cornerRadius(8)
                    
                    Text("Your identity is linked and trackable.")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Theme.Colors.error)
                }
                .padding(16)
                .background(Color.white)
                .cornerRadius(Theme.Radius.card)
                .shadow(color: Color.black.opacity(0.05), radius: 10, y: 5)
                .overlay(RoundedRectangle(cornerRadius: Theme.Radius.card).stroke(Theme.Colors.error.opacity(0.1), lineWidth: 1))
                
                Image(systemName: "arrow.down")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Theme.Colors.primary)
                
                // After Card
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("AFTER LINKDIVE")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Theme.Colors.success)
                        Spacer()
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(Theme.Colors.success)
                    }
                    
                    Text("instagram.com/reel/abc...")
                        .font(.system(size: 12, weight: .regular, design: .monospaced))
                        .foregroundColor(Theme.Colors.success)
                        .padding(12)
                        .background(Theme.Colors.success.opacity(0.05))
                        .cornerRadius(8)
                    
                    Text("Clean, private, and anonymous.")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Theme.Colors.success)
                }
                .padding(16)
                .background(Color.white)
                .cornerRadius(Theme.Radius.card)
                .shadow(color: Color.black.opacity(0.05), radius: 10, y: 5)
                .overlay(RoundedRectangle(cornerRadius: Theme.Radius.card).stroke(Theme.Colors.success.opacity(0.1), lineWidth: 1))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
            
            Text("We strip the trackers.\nYou keep your privacy.")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Color(hex: "0F172A"))
                .multilineTextAlignment(.center)
            
            Spacer()
        }
    }
}

// MARK: - Page 3: Final Pitch
struct OnboardingPage3: View {
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Theme.Colors.primary.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "shield.checkered")
                    .font(.system(size: 60))
                    .foregroundColor(Theme.Colors.primary)
            }
            
            VStack(spacing: 16) {
                Text("Privacy first, by default.")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(Color(hex: "0F172A"))
                
                Text("LinkDive works in the background to detect tracked links you copy and notifies you instantly so you can share without fear.")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(Color(hex: "64748B"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .lineSpacing(4)
            }
            
            VStack(alignment: .leading, spacing: 16) {
                Label("No data collected", systemImage: "checkmark.circle.fill")
                Label("Works on 6+ platforms", systemImage: "checkmark.circle.fill")
                Label("100% On-device processing", systemImage: "checkmark.circle.fill")
            }
            .font(.system(size: 15, weight: .medium))
            .foregroundColor(Color(hex: "0F172A"))
            
            Spacer()
        }
    }
}

struct FeatureChip: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(Theme.Colors.primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Theme.Colors.primary.opacity(0.1))
            .cornerRadius(16)
    }
}
