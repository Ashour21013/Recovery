import SwiftUI

/// Eigener Tab: Artikel zu jeder Sucht (Auswirkungen, Fakten, Methoden, Erfahrungen …).
struct ArticlesView: View {

    @Environment(\.dependencies) private var dependencies
    @AppStorage("articles.readIDs") private var readIDs = ""

    @State private var articles: [Article] = []
    @State private var filter: HabitType?
    @State private var didSetInitialFilter = false

    private var visible: [Article] {
        guard let filter else { return articles }
        return articles.filter { $0.habit == filter }
    }

    private var readSet: Set<String> { Set(readIDs.split(separator: ",").map(String.init)) }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 18) {
                    chips
                    ForEach(visible) { article in
                        NavigationLink {
                            ArticleDetailView(article: article)
                                .onAppear { markRead(article) }
                        } label: {
                            ArticleCard(article: article, isRead: readSet.contains(article.id))
                        }
                        .buttonStyle(.plain)
                    }
                    if visible.isEmpty {
                        ContentUnavailableView("Keine Artikel", systemImage: "text.book.closed")
                    }
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 24)
            }
            .background(AppColor.background.ignoresSafeArea())
            .navigationTitle("Artikel")
        }
        .tint(AppColor.teal)
        .task {
            if articles.isEmpty { articles = ArticleLibrary.load() }
            guard !didSetInitialFilter else { return }
            didSetInitialFilter = true
            let profile = try? await dependencies.makeRecoveryRepository().loadProfile()
            filter = profile?.habitType
        }
    }

    private var chips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                chip(title: String(localized: "Alle"), icon: "square.grid.2x2", selected: filter == nil) { filter = nil }
                ForEach(HabitType.allCases) { habit in
                    chip(title: habit.title, icon: habit.iconName, selected: filter == habit) { filter = habit }
                }
            }
            .padding(.vertical, 2)
        }
        .scrollClipDisabled()
    }

    private func chip(title: String, icon: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button {
            withAnimation(.snappy) { action() }
        } label: {
            Label(title, systemImage: icon)
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .foregroundStyle(selected ? .white : AppColor.ink)
                .background(Capsule().fill(selected ? AppColor.teal : AppColor.surface))
                .overlay(Capsule().stroke(AppColor.muted.opacity(selected ? 0 : 0.25), lineWidth: 1))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }

    private func markRead(_ article: Article) {
        var set = readSet
        guard set.insert(article.id).inserted else { return }
        readIDs = set.sorted().joined(separator: ",")
    }
}

/// Große Karte im Stil der Health-App: Cover oben, Titel + Untertitel darunter.
struct ArticleCard: View {
    let article: Article
    let isRead: Bool

    var body: some View {
        let theme = ArticleTheme(article: article)
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topLeading) {
                ArticleCoverView(theme: theme)
                    .frame(height: 190)
                HStack(spacing: 6) {
                    Label(article.category.title, systemImage: article.category.icon)
                    Text("·")
                    Text("\(article.readMinutes) Min.")
                }
                .font(.caption.weight(.bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(.black.opacity(0.35), in: Capsule())
                .padding(12)
            }
            .clipped()

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(article.habit.title.uppercased())
                        .font(.caption2.weight(.heavy))
                        .tracking(1.2)
                        .foregroundStyle(AppColor.teal)
                    Spacer()
                    if isRead {
                        Label("Gelesen", systemImage: "checkmark.circle.fill")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(AppColor.muted)
                    }
                }
                Text(article.title)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(AppColor.ink)
                    .multilineTextAlignment(.leading)
                Text(article.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(AppColor.muted)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
        }
        .background(AppColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .shadow(color: .black.opacity(0.07), radius: 10, y: 4)
        .accessibilityElement(children: .combine)
    }
}
