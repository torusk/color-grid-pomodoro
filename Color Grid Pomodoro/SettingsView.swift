import SwiftUI

struct SettingsView: View {
  @AppStorage("focusMinutes") var focusMinutes: Int = 25
  @AppStorage("breakMinutes") var breakMinutes: Int = 5
  @Environment(\.dismiss) private var dismiss

  let focusOptions = [15, 20, 25, 30, 45, 60]
  let breakOptions = [3, 5, 10, 15]

  var body: some View {
    NavigationStack {
      List {
        Section {
          Picker("Focus", selection: $focusMinutes) {
            ForEach(focusOptions, id: \.self) { min in
              Text("\(min) min").tag(min)
            }
          }

          Picker("Break", selection: $breakMinutes) {
            ForEach(breakOptions, id: \.self) { min in
              Text("\(min) min").tag(min)
            }
          }
        } header: {
          Text("Timer")
        } footer: {
          Text("Changes apply from the next session.")
        }

        Section("Color Theory") {
          colorTheoryRow("COMPLEMENTARY", description: "Opposite colors on the wheel", colors: [0, 6])
          colorTheoryRow("SPLIT COMP", description: "Base + two adjacent to complement", colors: [0, 5, 7])
          colorTheoryRow("TRIADIC", description: "Three evenly spaced colors", colors: [0, 4, 8])
          colorTheoryRow("TETRADIC", description: "Two complementary pairs", colors: [0, 2, 6, 8])
          colorTheoryRow("ANALOGOUS", description: "Neighboring colors", colors: [0, 1, 11])
        }

        Section {
          HStack {
            Text("Version")
            Spacer()
            Text("1.1.0")
              .foregroundColor(.secondary)
          }
        }
      }
      .navigationTitle("Settings")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button("Done") { dismiss() }
        }
      }
    }
  }

  private func colorTheoryRow(_ name: String, description: String, colors: [Int]) -> some View {
    HStack {
      VStack(alignment: .leading, spacing: 2) {
        Text(name)
          .font(.system(size: 13, weight: .semibold, design: .monospaced))
        Text(description)
          .font(.system(size: 12))
          .foregroundColor(.secondary)
      }
      Spacer()
      HStack(spacing: 4) {
        ForEach(colors, id: \.self) { i in
          Circle()
            .fill(hues[i % 12])
            .frame(width: 16, height: 16)
        }
      }
    }
    .padding(.vertical, 2)
  }
}
