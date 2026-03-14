import Foundation
import StoreKit

@MainActor
class IAPService: ObservableObject {
    static let shared = IAPService()
    
    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProductIDs = Set<String>()
    
    // Entitlement state
    @Published var isPro: Bool = false
    
    private let productIDs = [
        "com.linkdive.pro.weekly",
        "com.linkdive.pro.monthly",
        "com.linkdive.pro.lifetime"
    ]
    
    private var updates: Task<Void, Never>? = nil

    init() {
        // Start monitoring transactions
        updates = observeTransactionUpdates()
        
        Task {
            await fetchProducts()
            await updatePurchasedProducts()
        }
    }
    
    deinit {
        updates?.cancel()
    }
    
    func fetchProducts() async {
        do {
            let fetchedProducts = try await Product.products(for: productIDs)
            DispatchQueue.main.async {
                self.products = fetchedProducts.sorted(by: { $0.price < $1.price })
            }
        } catch {
            print("Failed to fetch products: \(error)")
        }
    }
    
    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await updatePurchasedProducts()
            await transaction.finish()
        case .userCancelled, .pending:
            break
        @unknown default:
            break
        }
    }
    
    func restore() async {
        do {
            try await AppStore.sync()
            await updatePurchasedProducts()
        } catch {
            print("Restore failed: \(error)")
        }
    }
    
    @MainActor
    func updatePurchasedProducts() async {
        var activeProductIDs = Set<String>()
        
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                activeProductIDs.insert(transaction.productID)
            } catch {
                print("Transaction verification failed")
            }
        }
        
        self.purchasedProductIDs = activeProductIDs
        self.isPro = !activeProductIDs.isEmpty
    }
    
    private func observeTransactionUpdates() -> Task<Void, Never> {
        Task(priority: .background) {
            for await _ in Transaction.updates {
                await updatePurchasedProducts()
            }
        }
    }
    
    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
}

enum StoreError: Error {
    case failedVerification
}
