import AudioToolbox
import Combine
import SwiftUI

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
  "COMPLEMENTARY", "ANALOGOUS", "TRIADIC", "SPLIT COMP", "TETRADIC",
]

struct ContentView: View {
  @State private var elapsedTime: TimeInterval = 0
  @State private var isRunning = false
  @State private var isBreakMode = false
  @State private var completedPomodoros: Int = 0
  @State private var taskName: String = ""
  @State private var showTaskInput = false
  @State private var taskInputDraft: String = ""

  let focusDuration: TimeInterval = 25 * 60
  let breakDuration: TimeInterval = 5 * 60
  var currentDuration: TimeInterval {
    isBreakMode ? breakDuration : focusDuration
  }

  let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

  var modeIndex: Int {
    min(Int(elapsedTime / 300), 4)
  }

  var baseIndex: Int {
    Int(elapsedTime / 25) % 12
  }

  private func playAlarmSound() {
    let soundID: SystemSoundID = 1007
    AudioServicesPlaySystemSound(soundID)
  }

  private func triggerHaptics() {
    let generator = UINotificationFeedbackGenerator()
    generator.prepare()
    generator.notificationOccurred(.success)
  }

  private func timeText(_ text: String, size: CGFloat) -> some View {
    Text(text)
      .font(.system(size: size, weight: .bold, design: .rounded))
      .foregroundStyle(.ultraThinMaterial)
      .overlay(
        Text(text)
          .font(.system(size: size, weight: .bold, design: .rounded))
          .foregroundColor(.white.opacity(0.85))
          .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 8)
      )
  }

  var body: some View {
    ZStack {
      // Background Grid Layer
      ColorGrid(modeIndex: modeIndex, baseIndex: baseIndex, isBreakMode: isBreakMode)
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 3), value: modeIndex)
        .animation(.easeInOut(duration: 3), value: baseIndex)

      // Central Info Layer
      GeometryReader { geo in
        let remaining = max(0, Int(currentDuration - elapsedTime))
        let minutes = remaining / 60
        let seconds = remaining % 60
        let isPortrait = geo.size.height > geo.size.width
        let minDim = min(geo.size.width, geo.size.height)
        let fontSize = minDim * 0.45

        ZStack {
          if isPortrait {
            VStack(spacing: 0) {
              ZStack {
                timeText("\(minutes)", size: fontSize)
              }
              .frame(width: geo.size.width, height: geo.size.height * 0.5)

              ZStack {
                timeText("\(String(format: "%02d", seconds))", size: fontSize)
              }
              .frame(width: geo.size.width, height: geo.size.height * 0.5)
            }

            HStack(spacing: minDim * 0.06) {
              Circle().fill(Color.white.opacity(0.9)).frame(
                width: minDim * 0.04, height: minDim * 0.04)
              Circle().fill(Color.white.opacity(0.9)).frame(
                width: minDim * 0.04, height: minDim * 0.04)
            }
            .shadow(color: .black.opacity(0.25), radius: 6, x: 0, y: 4)

          } else {
            HStack(spacing: 0) {
              ZStack {
                timeText("\(minutes)", size: fontSize)
              }
              .frame(width: geo.size.width * 0.5, height: geo.size.height)

              ZStack {
                timeText("\(String(format: "%02d", seconds))", size: fontSize)
              }
              .frame(width: geo.size.width * 0.5, height: geo.size.height)
            }

            VStack(spacing: minDim * 0.06) {
              Circle().fill(Color.white.opacity(0.9)).frame(
                width: minDim * 0.04, height: minDim * 0.04)
              Circle().fill(Color.white.opacity(0.9)).frame(
                width: minDim * 0.04, height: minDim * 0.04)
            }
            .shadow(color: .black.opacity(0.25), radius: 6, x: 0, y: 4)
          }

          // Bottom info: task name + mode label + pomodoro dots
          VStack {
            Spacer()
            VStack(spacing: 8) {
              if !taskName.isEmpty {
                Text(taskName)
                  .font(.system(size: 13, weight: .medium, design: .monospaced))
                  .foregroundColor(.white.opacity(0.75))
                  .tracking(2)
                  .lineLimit(1)
                  .truncationMode(.tail)
              }
              Text(isBreakMode ? "BREAK TIME" : modeNames[modeIndex])
                .font(.system(size: 14, weight: .medium, design: .monospaced))
                .foregroundColor(.white.opacity(0.8))
                .tracking(4)
              if completedPomodoros > 0 {
                HStack(spacing: 6) {
                  ForEach(0..<min(completedPomodoros, 8), id: \.self) { _ in
                    Circle()
                      .fill(Color.white.opacity(0.85))
                      .frame(width: 6, height: 6)
                  }
                  if completedPomodoros > 8 {
                    Text("+\(completedPomodoros - 8)")
                      .font(.system(size: 11, weight: .medium, design: .monospaced))
                      .foregroundColor(.white.opacity(0.75))
                  }
                }
                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
              }
            }
            .padding(.bottom, 52)
          }
        }
      }
      .ignoresSafeArea()
    }
    .onReceive(timer) { _ in
      if isRunning {
        if elapsedTime < currentDuration {
          elapsedTime += 1
        } else {
          if !isBreakMode {
            completedPomodoros += 1
          }
          isBreakMode.toggle()
          elapsedTime = 0
          playAlarmSound()
          triggerHaptics()
        }
      }
    }
    .onTapGesture {
      isRunning.toggle()
    }
    .onLongPressGesture {
      withAnimation(.easeInOut(duration: 1)) {
        isRunning = false
        isBreakMode = false
        elapsedTime = 0
        completedPomodoros = 0
      }
    }
    .gesture(
      DragGesture(minimumDistance: 40, coordinateSpace: .local)
        .onEnded { value in
          if value.translation.height < -40 {
            taskInputDraft = taskName
            showTaskInput = true
          }
        }
    )
    .sheet(isPresented: $showTaskInput) {
      TaskInputSheet(taskName: $taskName, draft: $taskInputDraft)
        .presentationDetents([.height(220)])
        .presentationDragIndicator(.visible)
    }
  }
}

struct TaskInputSheet: View {
  @Binding var taskName: String
  @Binding var draft: String
  @Environment(\.dismiss) private var dismiss
  @FocusState private var isFocused: Bool

  var body: some View {
    VStack(spacing: 24) {
      Text("CURRENT TASK")
        .font(.system(size: 12, weight: .medium, design: .monospaced))
        .foregroundColor(.secondary)
        .tracking(4)

      TextField("What are you working on?", text: $draft)
        .font(.system(size: 18, weight: .medium, design: .rounded))
        .multilineTextAlignment(.center)
        .focused($isFocused)
        .submitLabel(.done)
        .onSubmit {
          taskName = draft.trimmingCharacters(in: .whitespaces)
          dismiss()
        }

      HStack(spacing: 20) {
        Button("Clear") {
          draft = ""
          taskName = ""
          dismiss()
        }
        .font(.system(size: 15, weight: .medium, design: .rounded))
        .foregroundColor(.secondary)

        Button("Set") {
          taskName = draft.trimmingCharacters(in: .whitespaces)
          dismiss()
        }
        .font(.system(size: 15, weight: .semibold, design: .rounded))
        .buttonStyle(.borderedProminent)
        .tint(.black.opacity(0.8))
      }
    }
    .padding(32)
    .onAppear { isFocused = true }
  }
}

struct ColorGrid: View {
  let modeIndex: Int
  let baseIndex: Int
  let isBreakMode: Bool

  var body: some View {
    Group {
      if modeIndex == 0 {
        VStack(spacing: 0) {
          getColor(baseIndex)
          getColor(baseIndex + 6)
        }
        .transition(.opacity)
      } else if modeIndex == 1 {
        HStack(spacing: 0) {
          getColor(baseIndex)
          getColor(baseIndex + 1)
          getColor(baseIndex + 11)
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
          getColor(baseIndex)
          HStack(spacing: 0) {
            getColor(baseIndex + 5)
            getColor(baseIndex + 7)
          }
        }
        .transition(.opacity)
      } else {
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
      }
    }
  }

  private func getColor(_ index: Int) -> Color {
    let normalizedIndex = (index % 12 + 12) % 12
    if isBreakMode {
      return Color(white: 0.2 + 0.6 * Double(normalizedIndex) / 11.0)
    }
    return hues[normalizedIndex]
  }
}

#Preview {
  ContentView()
}
