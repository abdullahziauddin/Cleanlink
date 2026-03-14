import Foundation
import Combine
import UIKit

struct CleanedLink: Identifiable, Codable {
    var id: UUID = UUID()
    let originalURL: String
    let cleanURL: String
    let date: Date
}

@MainActor
class LinkDiveViewModel: ObservableObject {
    static let shared = LinkDiveViewModel()
    
    @Published var inputText: String = "" {
        didSet {
            if autoCleanEnabled {
                processLink(inputText)
            }
        }
    }
    
    @Published var cleanUrlText: String? = nil
    @Published var errorMessage: String? = nil
    @Published var isSuccessAnimationActive: Bool = false
    @Published var isPro: Bool = IAPService.shared.isPro
    private var cancellables = Set<AnyCancellable>()
    
    @Published var history: [CleanedLink] = []
    
    @Published var hasSeenOnboarding: Bool {
        didSet { UserDefaults.standard.set(hasSeenOnboarding, forKey: "hasSeenOnboarding") }
    }
    
    @Published var autoCleanEnabled: Bool {
        didSet { UserDefaults.standard.set(autoCleanEnabled, forKey: "autoCleanEnabled") }
    }
    
    @Published var saveHistoryEnabled: Bool {
        didSet { UserDefaults.standard.set(saveHistoryEnabled, forKey: "saveHistoryEnabled") }
    }
    
    init() {
        self.hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
        self.autoCleanEnabled = UserDefaults.standard.object(forKey: "autoCleanEnabled") as? Bool ?? true
        self.saveHistoryEnabled = UserDefaults.standard.object(forKey: "saveHistoryEnabled") as? Bool ?? true
        
        loadHistory()
        checkClipboardForSupportedLink()
        
        IAPService.shared.$isPro
            .receive(on: RunLoop.main)
            .sink { [weak self] status in
                self?.isPro = status
            }
            .store(in: &cancellables)
    }
    
    func processLink(_ text: String, manuallyTriggered: Bool = false) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            cleanUrlText = nil
            errorMessage = nil
            return
        }
        
        let cleanedText = LinkDiveParser.cleanText(text)
        let containsSupported = LinkDiveParser.containsSupportedLink(text: text)
        
        if cleanedText != text || containsSupported {
            cleanUrlText = cleanedText
            errorMessage = nil
            
            if saveHistoryEnabled {
                let platform = LinkDiveParser.identifyPlatform(for: trimmed)
                let original = platform != .unknown ? trimmed : "Multiple links / Text cleaned"
                
                let entry = CleanedLink(originalURL: original, cleanURL: cleanedText, date: Date())
                if !history.prefix(5).contains(where: { $0.originalURL == original && $0.cleanURL == cleanedText }) {
                    history.insert(entry, at: 0)
                    saveHistory()
                }
            }
        } else {
            cleanUrlText = nil
            if manuallyTriggered {
                errorMessage = "No supported tracking links found."
            } else {
                if let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue),
                   detector.firstMatch(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count)) != nil {
                    errorMessage = "Unsupported link type."
                } else {
                    errorMessage = nil
                }
            }
        }
    }
    
    func clearInput() {
        inputText = ""
        cleanUrlText = nil
        errorMessage = nil
    }
    
    func copyToClipboard() {
        guard let cleanUrl = cleanUrlText else { return }
        UIPasteboard.general.string = cleanUrl
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        isSuccessAnimationActive = true
        
        if !isPro {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                AdService.shared.incrementCopyCount(from: rootVC)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.isSuccessAnimationActive = false
        }
    }
    
    func checkClipboardForSupportedLink() {
        guard autoCleanEnabled, UIPasteboard.general.hasStrings, let string = UIPasteboard.general.string else { return }
        
        if LinkDiveParser.containsSupportedLink(text: string) {
            inputText = string
        }
    }
    
    // MARK: - Persistence
    
    private let historyKey = "CleanedLinkHistory"
    
    private func saveHistory() {
        if let data = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(data, forKey: historyKey)
        }
    }
    
    private func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: historyKey),
           let decoded = try? JSONDecoder().decode([CleanedLink].self, from: data) {
            self.history = decoded
        }
    }
    
    func removeHistory(at offsets: IndexSet) {
        history.remove(atOffsets: offsets)
        saveHistory()
    }
    
    func clearHistory() {
        history.removeAll()
        saveHistory()
    }
}
