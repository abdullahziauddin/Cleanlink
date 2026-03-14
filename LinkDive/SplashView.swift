import SwiftUI

struct SplashView: View {
    @Binding var isSplashing: Bool
    @State private var progress: CGFloat = 0.0
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 16) {
                    // Shield Icon with Gradient
                    ZStack {
                        LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "1A56DB"), Color(hex: "7C3AED")]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .frame(width: 64, height: 64)
                        .cornerRadius(16)
                        
                        // Shield Path
                        Image(systemName: "checkmark.shield.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 32)
                            .foregroundColor(.white)
                    }
                    
                    Text("LinkDive")
                        .font(.system(size: 32, weight: .bold, design: .default))
                        .foregroundColor(Color(hex: "0F172A"))
                    
                    Text("Privacy focused link sharing")
                        .font(.system(size: 15, weight: .regular, design: .default))
                        .foregroundColor(Color(hex: "64748B"))
                        .padding(.top, -8)
                }
                
                Spacer()
                
                // Progress Bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color(hex: "F3F4F6")) // Gray 100
                            .frame(height: 2)
                        
                        Rectangle()
                            .fill(Color(hex: "1A56DB")) // Brand
                            .frame(width: geo.size.width * progress, height: 2)
                    }
                }
                .frame(height: 2)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0)) {
                progress = 1.0
            }
            // Transition after the animation completes
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.1) {
                withAnimation {
                    isSplashing = false
                }
            }
        }
    }
}
