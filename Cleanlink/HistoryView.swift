import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var viewModel: CleanlinkViewModel
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.history.isEmpty {
                    VStack(spacing: Theme.Spacing.standard) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 60))
                            .foregroundColor(Theme.Colors.textSecondary.opacity(0.5))
                        
                        Text("No links cleaned yet.")
                            .font(Theme.Typography.headline)
                            .foregroundColor(Theme.Colors.textSecondary)
                    }
                } else {
                    List {
                        if !viewModel.isPro {
                            Section {
                                AdBannerView()
                                    .listRowInsets(EdgeInsets())
                                    .listRowBackground(Color.clear)
                            }
                        }
                        
                        ForEach(viewModel.history) { item in
                            HistoryRow(item: item)
                                .listRowBackground(Theme.Colors.surface)
                        }
                        .onDelete(perform: deleteItems)
                    }
                    .listStyle(InsetGroupedListStyle())
                    .scrollContentBackground(.hidden)
                    .standardBackground()
                }
            }
            .navigationTitle("History")
            .toolbar {
                if !viewModel.history.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Clear All") {
                            withAnimation { viewModel.clearHistory() }
                        }
                        .foregroundColor(Theme.Colors.error)
                    }
                }
            }
        }
    }
    
    private func deleteItems(at offsets: IndexSet) {
        viewModel.removeHistory(at: offsets)
    }
}

struct HistoryRow: View {
    let item: CleanedLink
    @State private var didCopy = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.micro) {
            HStack {
                Text(item.date, style: .date)
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
                
                Text(item.date, style: .time)
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.textSecondary)
                
                Spacer()
                
                Button(action: {
                    UIPasteboard.general.string = item.cleanURL
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                    
                    if !CleanlinkViewModel.shared.isPro {
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let rootVC = windowScene.windows.first?.rootViewController {
                            AdService.shared.incrementCopyCount(from: rootVC)
                        }
                    }
                    
                    withAnimation { didCopy = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation { didCopy = false }
                    }
                }) {
                    Image(systemName: didCopy ? "checkmark" : "doc.on.clipboard")
                        .foregroundColor(didCopy ? Theme.Colors.success : Theme.Colors.primary)
                }
                .buttonStyle(BorderlessButtonStyle())
            }
            
            Text(item.cleanURL)
                .font(Theme.Typography.monospaced)
                .foregroundColor(Theme.Colors.textPrimary)
                .lineLimit(1)
                .truncationMode(.tail)
        }
        .padding(.vertical, 4)
    }
}
