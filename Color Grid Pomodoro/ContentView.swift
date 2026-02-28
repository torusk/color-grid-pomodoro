import SwiftUI
import Combine

// Hex initializer
extension Color {
  init(hex: UInt, alpha: Double = 1) {
    self.init(
      .sRGB,
      red: Double((hex >> 16) & 0xff) / 255,
      green: Double((hex >> 08) & 0xff) / 255,
      blue: Double((hex >> 00) & 0xff) / 255,
      opacity: alpha
    )
  }
}

let hues: [Color] = [
  Color(hex: 0xFF0000), Color(hex: 0xFF7F00), Color(hex: 0xFFFF00),
  Color(hex: 0x7FFF00), Color(hex: 0x00FF00), Color(hex: 0x00FF7F),
  Color(hex: 0x00FFFF), Color(hex: 0x007FFF), Color(hex: 0x0000FF),
  Color(hex: 0x7F00FF), Color(hex: 0xFF00FF), Color(hex: 0xFF007F),
]

let modeNames = [
  "COMPLEMENTARY", "SPLIT COMP", "TRIADIC", "TETRADIC", "ANALOGOUS",
]

struct ContentView: View {
  @State private var elapsedTime: TimeInterval = 0
  @State private var isRunning = false

  let timerDuration: TimeInterval = 25 * 60  // 25 minutes

  let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

  var modeIndex: Int {
    min(Int(elapsedTime / 300), 4)
  }

  var baseIndex: Int {
    Int(elapsedTime / 25) % 12
  }

  var body: some View {
    ZStack {
      // Background Grid Layer
      ColorGrid(modeIndex: modeIndex, baseIndex: baseIndex)
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 3), value: modeIndex)
        .animation(.easeInOut(duration: 3), value: baseIndex)

      // Central Info Layer
      VStack(spacing: 4) {
        let remaining = max(0, Int(timerDuration - elapsedTime))
        Text("\(remaining / 60):\(String(format: "%02d", remaining % 60))")
          .font(.system(size: 64, weight: .ultraLight, design: .rounded))
          .foregroundColor(.white)
          .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)

        Text(modeNames[modeIndex])
          .font(.system(size: 14, weight: .medium, design: .monospaced))
          .foregroundColor(.white.opacity(0.8))
          .tracking(4)

      }
      .padding(32)
      .background(.ultraThinMaterial)
      .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
      .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)

      if !isRunning && elapsedTime == 0 {
        Text("TAP TO START")
          .font(.caption)
          .foregroundColor(.white)
          .padding(.top, 240)
          .opacity(0.6)
      }
    }
    .onReceive(timer) { input in
      if isRunning {
        if elapsedTime < timerDuration {
          elapsedTime += 1
        } else {
          isRunning = false
          elapsedTime = 0
        }
      }
    }
    .onTapGesture {
      isRunning.toggle()
    }
    .onLongPressGesture {
      withAnimation(.easeInOut(duration: 1)) {
        isRunning = false
        elapsedTime = 0
      }
    }
  }
}

struct ColorGrid: View {
  let modeIndex: Int
  let baseIndex: Int

  var body: some View {
    Group {
      if modeIndex == 0 {
        VStack(spacing: 0) {
          getColor(baseIndex)
          getColor(baseIndex + 6)
        }
        .transition(.opacity)
      } else if modeIndex == 1 {
        VStack(spacing: 0) {
          getColor(baseIndex)
          HStack(spacing: 0) {
            getColor(baseIndex + 5)
            getColor(baseIndex + 7)
          }
        }
        .transition(.opacity)
      } else if modeIndex == 2 {
        HStack(spacing: 0) {
          getColor(baseIndex)
          getColor(baseIndex + 4)
          getColor(baseIndex + 8)
        }
        .transition(.opacity)
      } else if modeIndex == 3 {
        VStack(spacing: 0) {
          HStack(spacing: 0) {
            getColor(baseIndex)
            getColor(baseIndex + 2)
          }
          HStack(spacing: 0) {
            getColor(baseIndex + 6)
            getColor(baseIndex + 8)
          }
        }
        .transition(.opacity)
      } else {
        HStack(spacing: 0) {
          getColor(baseIndex)
          getColor(baseIndex + 1)
          getColor(baseIndex + 11)
        }
        .transition(.opacity)
      }
    }
  }

  private func getColor(_ index: Int) -> Color {
    let normalizedIndex = (index % 12 + 12) % 12
    return hues[normalizedIndex]
  }
}

#Preview {
  ContentView()
}
