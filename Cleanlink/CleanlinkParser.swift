import Foundation

public enum CleanlinkPlatform: String, CaseIterable {
    case instagram = "Instagram"
    case tiktok = "TikTok"
    case x = "X (Twitter)"
    case youtube = "YouTube"
    case facebook = "Facebook"
    case linkedin = "LinkedIn"
    case unknown = "Unknown"
    
    var hosts: Set<String> {
        switch self {
        case .instagram: return ["instagram.com", "www.instagram.com", "instagr.am"]
        case .tiktok: return ["tiktok.com", "www.tiktok.com", "vm.tiktok.com", "vt.tiktok.com"]
        case .x: return ["x.com", "www.x.com", "twitter.com", "www.twitter.com", "t.co"]
        case .youtube: return ["youtube.com", "www.youtube.com", "m.youtube.com", "youtu.be"]
        case .facebook: return ["facebook.com", "www.facebook.com", "m.facebook.com", "fb.com", "fb.watch"]
        case .linkedin: return ["linkedin.com", "www.linkedin.com", "lnkd.in"]
        case .unknown: return []
        }
    }
    
    var trackingParameters: Set<String> {
        switch self {
        case .instagram: return ["igsh", "igshid", "utm_source", "utm_medium", "utm_campaign", "utm_content"]
        case .tiktok: return ["t", "_r", "utm_campaign", "utm_source", "utm_medium", "is_from_webapp", "share_app_id", "share_item_id", "share_link_id"]
        case .x: return ["s", "t", "utm_source", "utm_medium", "utm_campaign"]
        case .youtube: return ["si", "feature", "utm_source", "utm_medium", "utm_campaign", "pp"]
        case .facebook: return ["fbclid", "ref", "fbc", "utm_source", "utm_medium", "utm_campaign", "mibextid"]
        case .linkedin: return ["trackingId", "utm_source", "utm_medium", "utm_campaign", "trk"]
        case .unknown: return ["utm_source", "utm_medium", "utm_campaign", "utm_term", "utm_content"]
        }
    }
}

public struct CleanlinkParser {
    
    /// Identifies the platform for a given URL string.
    public static func identifyPlatform(for urlString: String) -> CleanlinkPlatform {
        guard let url = URL(string: urlString), let host = url.host?.lowercased() else {
            return .unknown
        }
        
        for platform in CleanlinkPlatform.allCases {
            if platform.hosts.contains(host) || platform.hosts.contains(where: { host.hasSuffix("." + $0) }) {
                return platform
            }
        }
        
        return .unknown
    }
    
    /// Checks if the URL string is supported by the parser
    public static func isSupported(urlString: String) -> Bool {
        return identifyPlatform(for: urlString) != .unknown
    }
    
    /// Parses and cleans a URL based on its platform's tracking parameters.
    public static func clean(urlString: String) -> String? {
        let trimmedURL = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let url = URL(string: trimmedURL),
              var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return nil
        }
        
        let platform = identifyPlatform(for: trimmedURL)
        guard platform != .unknown else {
            return nil
        }
        
        let trackingParams = platform.trackingParameters
        
        // Remove tracking query parameters
        if let queryItems = components.queryItems {
            let filteredItems = queryItems.filter { !trackingParams.contains($0.name.lowercased()) }
            components.queryItems = filteredItems.isEmpty ? nil : filteredItems
        }
        
        guard let cleanURL = components.url?.absoluteString else {
            return nil
        }
        
        return cleanURL
    }
    
    /// Extracts all supported URLs from a block of text, cleans them, and replaces them in the original text.
    public static func cleanText(_ text: String) -> String {
        guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else {
            return text
        }
        
        let matches = detector.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
        guard !matches.isEmpty else { return text }
        
        var resultText = text
        // Process in reverse to avoid shifting ranges
        for match in matches.reversed() {
            guard let url = match.url else { continue }
            let originalUrlString = url.absoluteString
            
            // Only clean if it's supported
            if identifyPlatform(for: originalUrlString) != .unknown, let cleanedUrlString = clean(urlString: originalUrlString) {
                if let range = Range(match.range, in: resultText) {
                    resultText.replaceSubrange(range, with: cleanedUrlString)
                }
            }
        }
        
        return resultText
    }
    
    /// Checks if a text block contains at least one supported URL
    public static func containsSupportedLink(text: String) -> Bool {
        guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else { return false }
        let matches = detector.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
        for match in matches {
            guard let url = match.url else { continue }
            if identifyPlatform(for: url.absoluteString) != .unknown {
                return true
            }
        }
        return false
    }
}
