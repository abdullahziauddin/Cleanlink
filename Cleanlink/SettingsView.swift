import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var viewModel: CleanlinkViewModel
    @State private var isShowingPaywall = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Button(action: { isShowingPaywall = true }) {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text("Upgrade to Pro")
                                .font(Theme.Typography.headline)
                                .foregroundColor(Theme.Colors.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Theme.Colors.textSecondary)
                        }
                    }
                }
                .listRowBackground(Theme.Colors.surface)
                
                Section(header: Text("General")) {
                    Toggle("Auto-clean from Clipboard", isOn: $viewModel.autoCleanEnabled)
                        .tint(Theme.Colors.primary)
                    
                    Toggle("Save History", isOn: $viewModel.saveHistoryEnabled)
                        .tint(Theme.Colors.primary)
                }
                .listRowBackground(Theme.Colors.surface)
                
                Section(header: Text("About")) {
                    Link(destination: URL(string: "https://cleanlink.app/privacy")!) {
                        SettingRow(title: "Privacy Policy", icon: "hand.raised.fill")
                    }
                    
                    Link(destination: URL(string: "mailto:support@cleanlink.app")!) {
                        SettingRow(title: "Contact Support", icon: "envelope.fill")
                    }
                    
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(Theme.Colors.textSecondary)
                            .frame(width: 24)
                        Text("App Version")
                            .foregroundColor(Theme.Colors.textPrimary)
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(Theme.Colors.textSecondary)
                    }
                }
                .listRowBackground(Theme.Colors.surface)
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Settings")
            .scrollContentBackground(.hidden)
            .standardBackground()
            .sheet(isPresented: $isShowingPaywall) {
                PaywallView()
            }
        }
    }
}

private struct SettingRow: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Theme.Colors.textSecondary)
                .frame(width: 24)
            Text(title)
                .foregroundColor(Theme.Colors.textPrimary)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Theme.Colors.textSecondary)
        }
    }
}
