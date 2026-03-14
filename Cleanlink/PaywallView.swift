import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: CleanlinkViewModel
    @ObservedObject private var iapService = IAPService.shared
    @State private var selectedPlan = 1
    @State private var isPurchasing = false
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Header
            HStack {
                Spacer()
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Theme.Colors.textSecondary)
                }
                .padding()
            }
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: Theme.Spacing.sectionMedium) {
                    
                    // Hero
                    VStack(spacing: Theme.Spacing.micro) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.yellow)
                            .padding(.bottom, Theme.Spacing.micro)
                        
                        Text("Unlock Cleanlink Pro")
                            .font(Theme.Typography.heroTitle)
                            .multilineTextAlignment(.center)
                        
                        Text("Take full control of your privacy.")
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Colors.textSecondary)
                    }
                    
                    // Already Pro Status
                    if viewModel.isPro {
                        HStack {
                            Image(systemName: "checkmark.seal.fill")
                            Text("You are a Pro Subscriber")
                        }
                        .font(Theme.Typography.headline)
                        .foregroundColor(Theme.Colors.success)
                        .padding()
                        .background(Theme.Colors.success.opacity(0.1))
                        .cornerRadius(Theme.Radius.card)
                    }
                    
                    // Benefits
                    VStack(alignment: .leading, spacing: Theme.Spacing.standard) {
                        BenefitRow(icon: "nosign", text: "Ad-free experience")
                        BenefitRow(icon: "infinity", text: "Unlimited auto-cleaning")
                        BenefitRow(icon: "shield.fill", text: "Support privacy development")
                    }
                    .padding(.horizontal)
                    
                    // Pricing Cards
                    VStack(spacing: Theme.Spacing.standard) {
                        if iapService.products.count >= 3 {
                            PricingCard(id: 0, title: iapService.products[0].displayName, price: iapService.products[0].displayPrice, selected: $selectedPlan)
                            PricingCard(id: 1, title: iapService.products[1].displayName, price: iapService.products[1].displayPrice, highlighted: true, selected: $selectedPlan)
                            PricingCard(id: 2, title: iapService.products[2].displayName, price: iapService.products[2].displayPrice, selected: $selectedPlan)
                        } else {
                            // Fallback if products are still loading or failed
                            PricingCard(id: 0, title: "Weekly", price: "$0.99", selected: $selectedPlan)
                            PricingCard(id: 1, title: "Monthly", price: "$2.99", highlighted: true, selected: $selectedPlan)
                            PricingCard(id: 2, title: "Lifetime", price: "$9.99", selected: $selectedPlan)
                        }
                    }
                    .padding(.horizontal)
                    .opacity(viewModel.isPro ? 0.5 : 1.0)
                    .disabled(viewModel.isPro)
                    
                    Spacer(minLength: 20)
                }
            }
            
            // Footer CTA
            VStack(spacing: Theme.Spacing.standard) {
                if !viewModel.isPro {
                    PrimaryButton(
                        title: isPurchasing ? "Processing..." : "Subscribe",
                        icon: isPurchasing ? nil : "creditcard.fill",
                        isSuccess: false
                    ) {
                        purchase()
                    }
                    .disabled(isPurchasing)
                } else {
                    PrimaryButton(title: "Dismiss", icon: nil, isSuccess: true) {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                HStack(spacing: Theme.Spacing.standard) {
                    LinkButton(title: "Restore") {
                        restore()
                    }
                    Text("•").foregroundColor(Theme.Colors.textSecondary)
                    LinkButton(title: "Terms") {
                        if let url = URL(string: "https://cleanlink.app/terms") {
                            UIApplication.shared.open(url)
                        }
                    }
                    Text("•").foregroundColor(Theme.Colors.textSecondary)
                    LinkButton(title: "Privacy") {
                        if let url = URL(string: "https://cleanlink.app/privacy") {
                            UIApplication.shared.open(url)
                        }
                    }
                }
                .font(Theme.Typography.caption)
            }
            .padding()
            .background(Theme.Colors.surface.shadow(radius: 10, y: -5))
        }
        .standardBackground()
        .onReceive(viewModel.$isPro) { isPro in
            if isPro {
                // If purchase becomes true while on this screen, dismiss
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
    
    private func purchase() {
        guard selectedPlan < IAPService.shared.products.count else {
            // Fallback if products haven't loaded yet
            print("Products not loaded yet")
            isPurchasing = false
            return
        }
        
        let product = IAPService.shared.products[selectedPlan]
        isPurchasing = true
        
        Task {
            do {
                try await IAPService.shared.purchase(product)
            } catch {
                print("Purchase failed: \(error)")
            }
            await MainActor.run {
                isPurchasing = false
            }
        }
    }
    
    private func restore() {
        Task {
            await IAPService.shared.restore()
        }
    }
}

private struct BenefitRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: Theme.Spacing.standard) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(Theme.Colors.primary)
                .frame(width: 30)
            
            Text(text)
                .font(Theme.Typography.body)
                .foregroundColor(Theme.Colors.textPrimary)
            
            Spacer()
        }
    }
}

private struct PricingCard: View {
    let id: Int
    let title: String
    let price: String
    var highlighted: Bool = false
    @Binding var selected: Int
    
    var isSelected: Bool { id == selected }
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selected = id
            }
        }) {
            HStack {
                VStack(alignment: .leading) {
                    Text(title)
                        .font(Theme.Typography.headline)
                        .foregroundColor(isSelected ? Theme.Colors.primary : Theme.Colors.textPrimary)
                    
                    if highlighted {
                        Text("Best Value")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Theme.Colors.primary)
                            .cornerRadius(16)
                    }
                }
                
                Spacer()
                
                Text(price)
                    .font(Theme.Typography.title)
                    .foregroundColor(Theme.Colors.textPrimary)
            }
            .padding()
            .background(Theme.Colors.surface)
            .cornerRadius(Theme.Radius.card)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.card)
                    .stroke(isSelected ? Theme.Colors.primary : Color(UIColor.quaternarySystemFill), lineWidth: isSelected ? 2 : 1)
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
