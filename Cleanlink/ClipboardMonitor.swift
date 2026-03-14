import Foundation
import UIKit
import Combine

public class ClipboardMonitor: ObservableObject {
    @Published public var copiedText: String = ""
    
    public init() {
        startMonitoring()
    }
    
    private func startMonitoring() {
        // Check on init
        checkClipboard()
        
        // Listen to app lifecycle events to check clipboard when returning to foreground
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(checkClipboard),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(checkClipboard),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    @objc private func checkClipboard() {
        if let string = UIPasteboard.general.string {
            // Only update if it contains an Instagram link
            if string.contains("instagram.com") || string.contains("instagr.am") {
                DispatchQueue.main.async {
                    self.copiedText = string
                }
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
