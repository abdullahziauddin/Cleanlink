import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: LinkDiveViewModel
    @State private var showClipboardBadge = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: Theme.Spacing.sectionSmall) {
                    
                    InputCard(text: $viewModel.inputText, showBadge: showClipboardBadge, errorMessage: viewModel.errorMessage) {
                        viewModel.clearInput()
                    }
                    
                    if let cleanUrl = viewModel.cleanUrlText {
                        OutputCard(cleanUrl: cleanUrl)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                            .zIndex(1)
                        
                        VStack(spacing: Theme.Spacing.standard) {
                            PrimaryButton(
                                title: viewModel.isSuccessAnimationActive ? "Copied!" : "Copy Clean Link",
                                icon: viewModel.isSuccessAnimationActive ? nil : "doc.on.clipboard",
                                isSuccess: viewModel.isSuccessAnimationActive
                            ) {
                                viewModel.copyToClipboard()
                            }
                            
                            SecondaryButton(
                                title: "Share",
                                icon: "square.and.arrow.up"
                            ) {
                                let shareSheet = UIActivityViewController(
                                    activityItems: [cleanUrl],
                                    applicationActivities: nil
                                )
                                if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene ?? UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                   let rootVC = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController ?? windowScene.windows.first?.rootViewController {
                                    rootVC.present(shareSheet, animated: true, completion: nil)
                                }
                            }
                        }
                    } else if !viewModel.inputText.isEmpty && !viewModel.autoCleanEnabled {
                        PrimaryButton(
                            title: "Clean Link",
                            icon: "wand.and.stars",
                            isSuccess: false
                        ) {
                            viewModel.processLink(viewModel.inputText, manuallyTriggered: true)
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .zIndex(1)
                    }
                    
                    Spacer(minLength: Theme.Spacing.sectionLarge)
                    
                    if !viewModel.isPro {
                        AdBannerView()
                            .padding(.bottom, Theme.Spacing.standard)
                    }
                    
                }
                .padding(.horizontal, Theme.Spacing.standard)
                .padding(.top, Theme.Spacing.standard)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.cleanUrlText)
            }
            .navigationTitle("LinkDive")
            .standardBackground()
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                checkClipboard()
            }
            .onAppear {
                checkClipboard()
            }
        }
    }
    
    private func checkClipboard() {
        if viewModel.autoCleanEnabled, UIPasteboard.general.hasStrings, let string = UIPasteboard.general.string, LinkDiveParser.containsSupportedLink(text: string) {
            if viewModel.inputText != string {
                withAnimation { showClipboardBadge = true }
                viewModel.inputText = string
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation { showClipboardBadge = false }
                }
            }
        }
    }
}
