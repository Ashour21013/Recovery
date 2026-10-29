import SwiftUI

/// Detailansicht: Kopf-Layout hängt von der Kategorie ab, Inhalte werden blockweise gerendert.
struct ArticleDetailView: View {
    let article: Article

    @Environment(\.openURL) private var openURL
    private var theme: ArticleTheme { ArticleTheme(article: article) }
    private var accent: Color { theme.dark.opacity(1) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                header
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(Array(article.blocks.enumerated()), id: \.offset) { _, block in
                        render(block)
                    }
                    sourcesSection
                    disclaimer
                }
                .padding(20)
            }
        }
        .background(AppColor.background.ignoresSafeArea())
        .ignoresSafeArea(edges: article.category.headerLayout == .overlay ? .top : [])
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: Kopf

    private var meta: some View {
        HStack(spacing: 6) {
            Label(article.category.title, systemImage: article.category.icon)
            Text("·")
            Text(article.habit.title)
            Text("·")
            Text("\(article.readMinutes) Min.")
        }
        .font(.caption.weight(.bold))
    }

    @ViewBuilder private var header: some View {
        switch article.category.headerLayout {
        case .overlay:
            ZStack(alignment: .bottomLeading) {
                ArticleCoverView(theme: theme).frame(height: 380)
                LinearGradient(colors: [.clear, .black.opacity(0.65)], startPoint: .center, endPoint: .bottom)
                VStack(alignment: .leading, spacing: 8) {
                    meta.foregroundStyle(.white.opacity(0.85))
                    Text(article.title).font(.largeTitle.weight(.heavy)).foregroundStyle(.white)
                    Text(article.subtitle).font(.callout).foregroundStyle(.white.opacity(0.9))
                }
                .padding(20)
            }
            .frame(height: 380)
            .clipped()

        case .stacked:
            VStack(alignment: .leading, spacing: 10) {
                ArticleCoverView(theme: theme).frame(height: 170)
                VStack(alignment: .leading, spacing: 8) {
                    meta.foregroundStyle(accent)
                    Text(article.title).font(.largeTitle.weight(.heavy)).foregroundStyle(AppColor.ink)
                    Text(article.subtitle).font(.callout).foregroundStyle(AppColor.muted)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }

        case .tinted:
            ZStack(alignment: .topTrailing) {
                theme.light.opacity(0.35)
                ArticleCoverView(theme: theme)
                    .frame(width: 150, height: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
                    .rotationEffect(.degrees(8))
                    .padding(.top, 20).padding(.trailing, 20)
                VStack(alignment: .leading, spacing: 8) {
                    Spacer(minLength: 120)
                    meta.foregroundStyle(accent)
                    Text(article.title).font(.largeTitle.weight(.heavy)).foregroundStyle(AppColor.ink)
                    Text(article.subtitle).font(.callout).foregroundStyle(AppColor.muted)
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    // MARK: Blöcke

    @ViewBuilder private func render(_ block: ArticleBlock) -> some View {
        switch block {
        case let .paragraph(text):
            Text(text).font(.body).foregroundStyle(AppColor.ink).lineSpacing(5)

        case let .heading(text):
            Text(text).font(.title3.weight(.bold)).foregroundStyle(AppColor.ink).padding(.top, 8)

        case let .stat(value, label):
            HStack(alignment: .center, spacing: 16) {
                Text(value)
                    .font(.system(size: 38, weight: .heavy, design: .rounded))
                    .foregroundStyle(accent)
                    .minimumScaleFactor(0.5).lineLimit(1)
                    .frame(minWidth: 96, alignment: .leading)
                Text(label).font(.subheadline).foregroundStyle(AppColor.ink)
                Spacer(minLength: 0)
            }
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(theme.light.opacity(0.35)))
            .accessibilityElement(children: .combine)

        case let .quote(text, attribution):
            HStack(alignment: .top, spacing: 14) {
                RoundedRectangle(cornerRadius: 2).fill(theme.mid).frame(width: 4)
                VStack(alignment: .leading, spacing: 8) {
                    Text("„\(text)“").font(.system(.title3, design: .serif).italic()).foregroundStyle(AppColor.ink)
                    if let attribution {
                        Text(attribution).font(.footnote.weight(.semibold)).foregroundStyle(AppColor.muted)
                    }
                }
            }
            .fixedSize(horizontal: false, vertical: true)

        case let .list(items):
            VStack(alignment: .leading, spacing: 10) {
                ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                    HStack(alignment: .firstTextBaseline, spacing: 12) {
                        Circle().fill(theme.mid).frame(width: 7, height: 7)
                        Text(item).font(.body).foregroundStyle(AppColor.ink).lineSpacing(4)
                    }
                }
            }

        case let .steps(steps):
            VStack(alignment: .leading, spacing: 16) {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .top, spacing: 14) {
                        Text("\(index + 1)")
                            .font(.subheadline.weight(.heavy))
                            .foregroundStyle(.white)
                            .frame(width: 30, height: 30)
                            .background(Circle().fill(accent))
                        VStack(alignment: .leading, spacing: 4) {
                            Text(step.title).font(.headline).foregroundStyle(AppColor.ink)
                            Text(step.text).font(.subheadline).foregroundStyle(AppColor.muted).lineSpacing(3)
                        }
                    }
                }
            }

        case let .callout(title, text):
            VStack(alignment: .leading, spacing: 6) {
                Label(title, systemImage: "lightbulb.fill").font(.headline).foregroundStyle(accent)
                Text(text).font(.subheadline).foregroundStyle(AppColor.ink).lineSpacing(4)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(theme.mid.opacity(0.18)))
        }
    }

    // MARK: Fuß

    @ViewBuilder private var sourcesSection: some View {
        if !article.sources.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("Quellen").font(.headline).foregroundStyle(AppColor.ink)
                ForEach(article.sources, id: \.self) { source in
                    if let url = source.url.flatMap(URL.init(string:)) {
                        Button { openURL(url) } label: {
                            Label(source.name, systemImage: "arrow.up.right.square")
                                .font(.footnote).multilineTextAlignment(.leading)
                        }
                    } else {
                        Text(source.name).font(.footnote).foregroundStyle(AppColor.muted)
                    }
                }
            }
            .padding(.top, 8)
        }
    }

    private var disclaimer: some View {
        Text("Diese Inhalte dienen der Information und ersetzen keine ärztliche oder therapeutische Beratung. Wenn du dich in einer Krise befindest, wende dich bitte an eine Beratungsstelle oder die Telefonseelsorge (0800 111 0 111).")
            .font(.caption)
            .foregroundStyle(AppColor.muted)
            .padding(.top, 4)
    }
}

extension ArticleCategory {
    enum HeaderLayout { case overlay, stacked, tinted }

    var headerLayout: HeaderLayout {
        switch self {
        case .impact, .stories: .overlay
        case .facts, .methods: .stacked
        case .recovery, .triggers: .tinted
        }
    }
}
