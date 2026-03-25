import SwiftUI

struct OnboardingView: View {
  @Binding var hasSeenOnboarding: Bool
  @State private var currentPage = 0

  var body: some View {
    ZStack {
      // Animated background matching main app
      ColorGrid(modeIndex: currentPage, baseIndex: currentPage * 3, isBreakMode: false)
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 1.5), value: currentPage)

      VStack(spacing: 0) {
        Spacer()

        // Content
        TabView(selection: $currentPage) {
          onboardingPage(
            title: "Color Grid\nPomodoro",
            subtitle: "色彩理論を体感しながら\n集中する25分間",
            hint: nil
          )
          .tag(0)

          onboardingPage(
            title: "5つの配色理論",
            subtitle: "補色・類似色・トライアド…\n5分ごとに画面レイアウトが変化",
            hint: "25分間で色彩の基本を体験"
          )
          .tag(1)

          onboardingPage(
            title: "シンプル操作",
            subtitle: "タップで開始・停止\n長押しでリセット",
            hint: nil
          )
          .tag(2)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(height: 280)

        // Page indicator
        HStack(spacing: 10) {
          ForEach(0..<3, id: \.self) { i in
            Circle()
              .fill(Color.white.opacity(i == currentPage ? 0.9 : 0.3))
              .frame(width: 8, height: 8)
          }
        }
        .padding(.bottom, 32)

        // Button
        Button {
          if currentPage < 2 {
            withAnimation { currentPage += 1 }
          } else {
            hasSeenOnboarding = true
          }
        } label: {
          Text(currentPage < 2 ? "Next" : "Start")
            .font(.system(size: 17, weight: .semibold, design: .rounded))
            .foregroundColor(.black)
            .frame(width: 200, height: 50)
            .background(Color.white.opacity(0.9))
            .clipShape(Capsule())
        }
        .padding(.bottom, 24)

        if currentPage < 2 {
          Button("Skip") {
            hasSeenOnboarding = true
          }
          .font(.system(size: 14, weight: .regular, design: .rounded))
          .foregroundColor(.white.opacity(0.5))
          .padding(.bottom, 48)
        } else {
          Color.clear.frame(height: 62)
        }
      }
    }
  }

  private func onboardingPage(title: String, subtitle: String, hint: String?) -> some View {
    VStack(spacing: 16) {
      Text(title)
        .font(.system(size: 32, weight: .bold, design: .rounded))
        .foregroundColor(.white)
        .multilineTextAlignment(.center)
        .shadow(color: .black.opacity(0.3), radius: 12, x: 0, y: 6)

      Text(subtitle)
        .font(.system(size: 17, weight: .regular, design: .rounded))
        .foregroundColor(.white.opacity(0.8))
        .multilineTextAlignment(.center)
        .lineSpacing(4)
        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)

      if let hint = hint {
        Text(hint)
          .font(.system(size: 13, weight: .medium, design: .monospaced))
          .foregroundColor(.white.opacity(0.5))
          .tracking(2)
          .padding(.top, 8)
      }
    }
    .padding(.horizontal, 40)
  }
}
