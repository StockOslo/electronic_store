import SwiftUI

struct CategoriesScreen: View {

    @StateObject private var categoriesManager = CategoriesManager()

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    Text("categoryLabel")
                        .font(.largeTitle.bold())
                        .padding(.horizontal, 20)
                        .padding(.top, 12)

                    if categoriesManager.isLoading {
                        ProgressView()
                            .padding(.horizontal, 20)
                            .padding(.top, 10)

                    } else if let err = categoriesManager.errorMessage {
                        Text(LocalizedStringKey(err))
                            .foregroundColor(.red)
                            .padding(.horizontal, 20)

                    } else {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(categoriesManager.categories) { category in
                                NavigationLink {
                                    CategoriesProductFeed(
                                        categoryId: category.id,
                                        categoryName: category.name
                                    )
                                } label: {
                                    VStack(spacing: 12) {
                                        Image(systemName: category.systemImageName ?? "tag")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 60)
                                            .foregroundStyle(.blue)

                                        Text(LocalizedStringKey(category.name))
                                            .font(.headline)
                                            .multilineTextAlignment(.center)
                                            .foregroundStyle(.primary)
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity, minHeight: 140)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color.white)
                                            .shadow(color: .gray.opacity(0.2), radius: 6, x: 0, y: 3)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.top, 4)
            }
            .background(Color.white)
            .task {
                await categoriesManager.loadCategories()
            }
        }
    }
}
