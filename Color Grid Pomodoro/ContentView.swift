import AudioToolbox
import Combine
import SwiftUI
import UserNotifications

// MARK: - Color Hex Extension

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

// MARK: - ContentView

struct ContentView: View {
  @Environment(\.scenePhase) private var scenePhase
  @AppStorage("focusMinutes") private var focusMinutes: Int = 25
  @AppStorage("breakMinutes") private var breakMinutes: Int = 5

  @State private var elapsedTime: TimeInterval = 0
  @State private var isRunning = false
  @State private var isBreakMode = false
  @State private var completedPomodoros: Int = 0
  @State private var showSettings = false
  @State private var backgroundedAt: Date? = nil
  @State private var notificationPermissionGranted = false

  private var focusDuration: TimeInterval { TimeInterval(focusMinutes * 60) }
  private var breakDuration: TimeInterval { TimeInterval(breakMinutes * 60) }
  private var currentDuration: TimeInterval { isBreakMode ? breakDuration : focusDuration }

  let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

  var modeIndex: Int {
    let interval = focusDuration / 5
    return min(Int(elapsedTime / interval), 4)
  }

  var baseIndex: Int {
    Int(elapsedTime / 25) % 12
  }

  // MARK: - Notifications

  private func checkNotificationPermission() {
    UNUserNotificationCenter.current().getNotificationSettings { settings in
      DispatchQueue.main.async {
        notificationPermissionGranted = settings.authorizationStatus == .authorized
      }
    }
  }

  private func requestNotificationPermission() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) {
      granted, _ in
      DispatchQueue.main.async {
        notificationPermissionGranted = granted
      }
    }
  }

  private func scheduleNotification() {
    guard notificationPermissionGranted else { return }
    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    let remaining = currentDuration - elapsedTime
    guard remaining > 0 else { return }

    let content = UNMutableNotificationContent()
    if isBreakMode {
      content.title = "Break over!"
      content.body = "Time to focus."
    } else {
      content.title = "Focus complete!"
      content.body = "Well done. Time for a break."
    }
    content.sound = .default

    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: remaining, repeats: false)
    let request = UNNotificationRequest(identifier: "session-end", content: content, trigger: trigger)
    UNUserNotificationCenter.current().add(request)
  }

  private func cancelNotification() {
    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
  }

  // MARK: - Background Sync

  private func advanceTimer(by seconds: TimeInterval) {
    var remaining = seconds
    while remaining > 0 {
      let timeLeft = currentDuration - elapsedTime
      if remaining < timeLeft {
        elapsedTime += remaining
        remaining = 0
      } else {
        remaining -= timeLeft
        if !isBreakMode {
          completedPomodoros += 1
          savePomodoros()
        }
        isBreakMode.toggle()
        elapsedTime = 0
      }
    }
  }

  // MARK: - Persistence

  private func loadSavedData() {
    let today = Calendar.current.startOfDay(for: Date())
    if let saved = UserDefaults.standard.object(forKey: "pomodoroDate") as? Date,
      Calendar.current.isDate(saved, inSameDayAs: today)
    {
      completedPomodoros = UserDefaults.standard.integer(forKey: "completedPomodoros")
    } else {
      completedPomodoros = 0
      UserDefaults.standard.set(today, forKey: "pomodoroDate")
      UserDefaults.standard.set(0, forKey: "completedPomodoros")
    }
  }

  private func savePomodoros() {
    UserDefaults.standard.set(completedPomodoros, forKey: "completedPomodoros")
    let today = Calendar.current.startOfDay(for: Date())
    UserDefaults.standard.set(today, forKey: "pomodoroDate")
  }

  // MARK: - Sound & Haptics

  private func playAlarmSound() {
    AudioServicesPlaySystemSound(1007)
  }

  private func triggerHaptics() {
    let g = UINotificationFeedbackGenerator()
    g.prepare()
    g.notificationOccurred(.success)
  }

  // MARK: - Helpers

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

  // MARK: - Body

  var body: some View {
    ZStack {
      // Background
      ColorGrid(modeIndex: modeIndex, baseIndex: baseIndex, isBreakMode: isBreakMode)
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 3), value: modeIndex)
        .animation(.easeInOut(duration: 3), value: baseIndex)

      // Timer display
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
              ZStack { timeText("\(minutes)", size: fontSize) }
                .frame(width: geo.size.width, height: geo.size.height * 0.5)
              ZStack { timeText(String(format: "%02d", seconds), size: fontSize) }
                .frame(width: geo.size.width, height: geo.size.height * 0.5)
            }
            HStack(spacing: minDim * 0.06) {
              Circle().fill(Color.white.opacity(0.9))
                .frame(width: minDim * 0.04, height: minDim * 0.04)
              Circle().fill(Color.white.opacity(0.9))
                .frame(width: minDim * 0.04, height: minDim * 0.04)
            }
            .shadow(color: .black.opacity(0.25), radius: 6, x: 0, y: 4)
          } else {
            HStack(spacing: 0) {
              ZStack { timeText("\(minutes)", size: fontSize) }
                .frame(width: geo.size.width * 0.5, height: geo.size.height)
              ZStack { timeText(String(format: "%02d", seconds), size: fontSize) }
                .frame(width: geo.size.width * 0.5, height: geo.size.height)
            }
            VStack(spacing: minDim * 0.06) {
              Circle().fill(Color.white.opacity(0.9))
                .frame(width: minDim * 0.04, height: minDim * 0.04)
              Circle().fill(Color.white.opacity(0.9))
                .frame(width: minDim * 0.04, height: minDim * 0.04)
            }
            .shadow(color: .black.opacity(0.25), radius: 6, x: 0, y: 4)
          }

          // Bottom info
          VStack {
            Spacer()
            VStack(spacing: 8) {
              // Mode name
              Text(isBreakMode ? "BREAK TIME" : modeNames[modeIndex])
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundColor(.white.opacity(0.55))
                .tracking(4)

              // Pomodoro count
              if completedPomodoros > 0 {
                HStack(spacing: 6) {
                  ForEach(0..<min(completedPomodoros, 8), id: \.self) { _ in
                    Circle().fill(Color.white.opacity(0.75))
                      .frame(width: 6, height: 6)
                  }
                  if completedPomodoros > 8 {
                    Text("+\(completedPomodoros - 8)")
                      .font(.system(size: 11, weight: .medium, design: .monospaced))
                      .foregroundColor(.white.opacity(0.55))
                  }
                }
                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
              }
            }
            .padding(.bottom, 52)
          }

          // Settings button (top-right)
          VStack {
            HStack {
              Spacer()
              Button {
                showSettings = true
              } label: {
                Image(systemName: "gearshape")
                  .font(.system(size: 18, weight: .medium))
                  .foregroundColor(.white.opacity(0.5))
                  .frame(width: 44, height: 44)
              }
              .accessibilityLabel("Settings")
            }
            .padding(.top, 8)
            .padding(.trailing, 12)
            Spacer()
          }
        }
      }
      .ignoresSafeArea()
    }
    .onAppear {
      checkNotificationPermission()
      loadSavedData()
    }
    .onChange(of: scenePhase) { _, newPhase in
      switch newPhase {
      case .background:
        if isRunning {
          backgroundedAt = Date()
          scheduleNotification()
        }
      case .active:
        if isRunning, let bg = backgroundedAt {
          advanceTimer(by: Date().timeIntervalSince(bg))
          backgroundedAt = nil
          cancelNotification()
          if isRunning { scheduleNotification() }
        }
        checkNotificationPermission()
      default:
        break
      }
    }
    .onReceive(timer) { _ in
      guard isRunning else { return }
      if elapsedTime < currentDuration {
        elapsedTime += 1
      } else {
        if !isBreakMode {
          completedPomodoros += 1
          savePomodoros()
        }
        isBreakMode.toggle()
        elapsedTime = 0
        playAlarmSound()
        triggerHaptics()
        scheduleNotification()
      }
    }
    .onTapGesture {
      // Request notification permission on first tap (contextual)
      if !notificationPermissionGranted {
        requestNotificationPermission()
      }
      isRunning.toggle()
      isRunning ? scheduleNotification() : cancelNotification()
    }
    .onLongPressGesture {
      withAnimation(.easeInOut(duration: 1)) {
        isRunning = false
        isBreakMode = false
        elapsedTime = 0
      }
      cancelNotification()
    }
    .sheet(isPresented: $showSettings) {
      SettingsView()
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
  }
}

// MARK: - ColorGrid

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
    let i = (index % 12 + 12) % 12
    return isBreakMode ? Color(white: 0.2 + 0.6 * Double(i) / 11.0) : hues[i]
  }
}

#Preview {
  ContentView()
}
