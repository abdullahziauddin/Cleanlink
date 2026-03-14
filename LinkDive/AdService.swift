import Foundation
import GoogleMobileAds
import SwiftUI

@MainActor
class AdService: NSObject, ObservableObject {
    static let shared = AdService()
    
    // Ad Unit IDs - These are test IDs from Google
    // Replace with real IDs later
    let bannerAdUnitID = "ca-app-pub-3940256069382041/2934735716"
    let interstitialAdUnitID = "ca-app-pub-3940256069382041/4411468910"
    
    @Published var interstitial: GADInterstitialAd?
    
    // Frequency Capping Logic
    private var copyCountSinceLastAd = 0
    private var sessionAdCount = 0
    private let maxAdsPerSession = 3
    private let copiesPerAd = 5
    
    private let installDateKey = "app_install_date"
    
    override init() {
        super.init()
        checkInstallDate()
        loadInterstitial()
    }
    
    private func checkInstallDate() {
        if UserDefaults.standard.object(forKey: installDateKey) == nil {
            UserDefaults.standard.set(Date(), forKey: installDateKey)
        }
    }
    
    var isFirstDay: Bool {
        guard let installDate = UserDefaults.standard.object(forKey: installDateKey) as? Date else { return true }
        return Calendar.current.isDateInToday(installDate)
    }
    
    func loadInterstitial() {
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID: interstitialAdUnitID, request: request) { [weak self] ad, error in
            Task { @MainActor in
                if let error = error {
                    print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                    return
                }
                self?.interstitial = ad
                self?.interstitial?.fullScreenContentDelegate = self
            }
        }
    }
    
    func incrementCopyCount(from root: UIViewController) {
        // Only track if not Pro and not first day
        if IAPService.shared.isPro || isFirstDay { return }
        
        copyCountSinceLastAd += 1
        
        if copyCountSinceLastAd >= copiesPerAd && sessionAdCount < maxAdsPerSession {
            showInterstitial(from: root)
        }
    }
    
    private func showInterstitial(from root: UIViewController) {
        guard let interstitial = interstitial else {
            return
        }
        
        interstitial.present(fromRootViewController: root)
    }
}

extension AdService: GADFullScreenContentDelegate {
    nonisolated func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        Task { @MainActor in
            copyCountSinceLastAd = 0
            sessionAdCount += 1
            loadInterstitial() // Preload next one
        }
    }
    
    nonisolated func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        Task { @MainActor in
            print("Ad failed to present with error: \(error.localizedDescription)")
            loadInterstitial()
        }
    }
}

// SwiftUI Helper for Banner Views
struct BannerAdView: UIViewControllerRepresentable {
    let adUnitID: String
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        let bannerView = GADBannerView(adSize: GADAdSizeBanner)
        
        bannerView.adUnitID = adUnitID
        bannerView.rootViewController = viewController
        bannerView.load(GADRequest())
        
        viewController.view.addSubview(bannerView)
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bannerView.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor),
            bannerView.centerYAnchor.constraint(equalTo: viewController.view.centerYAnchor)
        ])
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

// Main entry point for Banner Ads in SwiftUI
struct AdBannerView: View {
    var body: some View {
        BannerAdView(adUnitID: AdService.shared.bannerAdUnitID)
            .frame(height: 50)
    }
}
