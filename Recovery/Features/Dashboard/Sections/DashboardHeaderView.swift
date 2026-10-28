import SwiftUI

/// Begrüßung oben im Dashboard (Figma): Datum als Eyebrow + „Guten Morgen“.
struct DashboardHeaderView: View {
    var name: String?

    private var greeting: String {
        switch Calendar.current.component(.hour, from: .now) {
        case 5..<11: String(localized: "Guten Morgen")
        case 11..<17: String(localized: "Hallo")
        case 17..<22: String(localized: "Guten Abend")
        default: String(localized: "Gute Nacht")
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Eyebrow(Date.now.formatted(.dateTime.weekday(.wide).day().month(.wide)))
            Text("\(greeting)\(Text(name.map { ", \($0)" } ?? "").foregroundStyle(AppColor.teal))")
                .font(.system(size: 27, weight: .bold))
                .foregroundStyle(AppColor.ink)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 2)
        .padding(.top, 6)
    }
}
