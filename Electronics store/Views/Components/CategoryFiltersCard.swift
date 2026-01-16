import SwiftUI

struct CategoryFiltersCard: View {
    @State private var isExpanded = false
    @State private var selected: [String: String] = [:]

    @State private var showOptionsSheet = false
    @State private var activeFilterTitle: String = ""
    @State private var activeOptions: [String] = []

    let filters: [(title: String, options: [String])]
    let isLoading: Bool

    let onSelect: (_ specName: String, _ value: String?) -> Void

    private let topAnchorId = "filters_top_anchor"

    var body: some View {
        ScrollViewReader { proxy in
            VStack(alignment: .leading, spacing: 12) {

                Color.clear.frame(height: 1).id(topAnchorId)

                Text("filtersTitleLabel")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.gray)

                Divider()

                if isLoading {
                    ProgressView().padding(.vertical, 6)
                } else if filters.isEmpty {
                    Text("Фильтров нет")
                        .foregroundColor(.gray)
                        .padding(.vertical, 6)
                } else {
                    VStack(spacing: 14) {
                        ForEach(displayedFilters, id: \.title) { filter in
                            filterRow(filter: filter)
                        }
                    }
                    .animation(.easeInOut(duration: 0.25), value: isExpanded)

                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                            isExpanded.toggle()
                        }
                        if isExpanded == false {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    proxy.scrollTo(topAnchorId, anchor: .top)
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Spacer()
                            Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.gray.opacity(0.8))
                                .padding(.top, 6)
                            Spacer()
                        }
                        .accessibilityLabel(Text(isExpanded ? "showLessButtonLabel" : "showMoreButtonLabel"))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: .gray.opacity(0.25), radius: 8, x: 0, y: 4)
            )
            .sheet(isPresented: $showOptionsSheet) {
                optionsSheet()
            }
        }
    }

    @ViewBuilder
    private func filterRow(filter: (title: String, options: [String])) -> some View {
        let chosen = selected[filter.title] ?? ""

        Button {
            activeFilterTitle = filter.title
            activeOptions = Array(Set(filter.options)).sorted()
            showOptionsSheet = true
        } label: {
            HStack(spacing: 10) {
                Text(filter.title + ":")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.gray)
                    .lineLimit(1)

                Spacer(minLength: 8)

                Text(chosen.isEmpty ? "Выбрать" : truncate(chosen, limit: 18))
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(chosen.isEmpty ? .gray.opacity(0.8) : .blue)
                    .lineLimit(1)

                Image(systemName: "chevron.down")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.gray.opacity(0.8))
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.08))
            )
        }
        .buttonStyle(.plain)
    }

    private func optionsSheet() -> some View {
        NavigationStack {
            List {
                Button {
                    selected = [:]
                    onSelect(activeFilterTitle, nil)
                    showOptionsSheet = false
                } label: {
                    HStack {
                        Text("Выбрать")
                        Spacer()
                        if (selected[activeFilterTitle] ?? "").isEmpty {
                            Image(systemName: "checkmark").foregroundColor(.blue)
                        }
                    }
                }

                ForEach(activeOptions, id: \.self) { option in
                    Button {
                        selected = [activeFilterTitle: option]
                        onSelect(activeFilterTitle, option)
                        showOptionsSheet = false
                    } label: {
                        HStack {
                            Text(option).lineLimit(1)
                            Spacer()
                            if (selected[activeFilterTitle] ?? "") == option {
                                Image(systemName: "checkmark").foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle(activeFilterTitle)
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var displayedFilters: [(title: String, options: [String])] {
        isExpanded ? filters : Array(filters.prefix(4))
    }

    private func truncate(_ text: String, limit: Int) -> String {
        guard text.count > limit else { return text }
        let idx = text.index(text.startIndex, offsetBy: max(0, limit - 1))
        return String(text[..<idx]) + "…"
    }
}
