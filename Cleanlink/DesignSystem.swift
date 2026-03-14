import SwiftUI

enum Theme {
    enum Colors {
        static let primary = Color(hex: "1A56DB")
        static let success = Color(hex: "059669")
        static let error = Color(hex: "DC2626")
        
        static let background = Color(UIColor.systemBackground)
        static let surface = Color(UIColor.secondarySystemBackground)
        static let border = Color(UIColor.separator)
        
        static let textPrimary = Color.primary
        static let textSecondary = Color.secondary
    }
    
    enum Typography {
        static let heroTitle = Font.system(size: 34, weight: .heavy, design: .default)
        static let title = Font.system(size: 24, weight: .bold, design: .default)
        static let headline = Font.system(size: 17, weight: .semibold, design: .default)
        static let body = Font.system(size: 17, weight: .regular, design: .default)
        static let caption = Font.system(size: 13, weight: .regular, design: .default)
        static let monospaced = Font.system(size: 15, weight: .regular, design: .monospaced)
    }
    
    enum Spacing {
        static let micro: CGFloat = 8 // 4 or 8
        static let standard: CGFloat = 16
        static let sectionSmall: CGFloat = 24
        static let sectionMedium: CGFloat = 32
        static let sectionLarge: CGFloat = 48
    }
    
    enum Radius {
        static let button: CGFloat = 16
        static let card: CGFloat = 16
        static let sheet: CGFloat = 24
    }
}

// Color Hex Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

extension View {
    func standardBackground() -> some View {
        self.background(Color(UIColor.systemBackground).ignoresSafeArea())
    }
    func surfaceBackground() -> some View {
        self.background(Color(UIColor.secondarySystemBackground).ignoresSafeArea())
    }
}
