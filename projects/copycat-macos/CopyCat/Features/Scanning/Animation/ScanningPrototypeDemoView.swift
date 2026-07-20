import SwiftUI

/// Side-by-side prototype host to compare normal vs compact scanning layouts.
struct ScanningPrototypeDemoView: View {
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Normal scanning size")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                ScanningScreenPrototypeView(compact: false)
                    .frame(minWidth: 520, minHeight: 520)
                    .background(RoundedRectangle(cornerRadius: 12).strokeBorder(.quaternary))
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Smaller window")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                ScanningScreenPrototypeView(compact: true)
                    .frame(width: 360, height: 520)
                    .background(RoundedRectangle(cornerRadius: 12).strokeBorder(.quaternary))
            }
        }
        .padding(16)
        .frame(minWidth: 940, minHeight: 600)
    }
}

#Preview {
    ScanningPrototypeDemoView()
}
