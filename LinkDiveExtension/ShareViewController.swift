import UIKit
import Social
import MobileCoreServices
import UniformTypeIdentifiers

@objc(ShareViewController)
class ShareViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        
        handleSharedURL()
    }
    
    private func handleSharedURL() {
        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
              let attachments = extensionItem.attachments,
              let itemProvider = attachments.first else {
            self.completeRequest()
            return
        }
        
        if itemProvider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
            itemProvider.loadItem(forTypeIdentifier: UTType.url.identifier, options: nil) { [weak self] (url, error) in
                guard let self = self, let sharedURL = url as? URL else {
                    self?.completeRequest()
                    return
                }
                
                let originalString = sharedURL.absoluteString
                
                if LinkDiveParser.isSupported(urlString: originalString),
                   let cleanedUrlString = LinkDiveParser.clean(urlString: originalString) {
                    UIPasteboard.general.string = cleanedUrlString
                    self.showSuccessToast()
                } else {
                    self.completeRequest()
                    return
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    self.completeRequest()
                }
            }
        } else if itemProvider.hasItemConformingToTypeIdentifier(UTType.text.identifier) {
            itemProvider.loadItem(forTypeIdentifier: UTType.text.identifier, options: nil) { [weak self] (text, error) in
                guard let self = self, let sharedString = text as? String else {
                    self?.completeRequest()
                    return
                }
                
                if LinkDiveParser.containsSupportedLink(text: sharedString) {
                    let cleanedText = LinkDiveParser.cleanText(sharedString)
                    UIPasteboard.general.string = cleanedText
                    self.showSuccessToast()
                } else {
                    self.completeRequest()
                    return
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    self.completeRequest()
                }
            }
        } else {
            self.completeRequest()
        }
    }
    
    private func showSuccessToast() {
        DispatchQueue.main.async {
            let toast = UILabel(frame: CGRect(x: 0, y: 0, width: 220, height: 44))
            toast.text = "Link Cleaned & Copied!"
            toast.font = .systemFont(ofSize: 15, weight: .semibold)
            toast.textAlignment = .center
            toast.backgroundColor = UIColor(white: 0.1, alpha: 0.95)
            toast.textColor = .white
            toast.layer.cornerRadius = 22
            toast.clipsToBounds = true
            toast.center = self.view.center
            self.view.addSubview(toast)
            
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
    }
    
    private func completeRequest() {
        DispatchQueue.main.async {
            self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
        }
    }
}
