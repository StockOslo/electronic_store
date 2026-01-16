import SwiftUI

struct ReviewsScreen: View {

    let productId: String

    @StateObject private var productManager = ProductManager()

    @State private var selectedRating = "Все отзывы"
    @State private var selectedSort = "Новые отзывы"

    private let ratingOptions = [
        "Все отзывы",
        "5 звезд",
        "4 звезды",
        "3 звезды"
    ]

    private let sortOptions = [
        "Новые отзывы",
        "Старые отзывы",
        "Лушие",
        "Худшие"
    ]

    private let columns = [GridItem(.flexible())]

    var body: some View {
        VStack(spacing: 0) {

            HStack {
                Text("reviewsTitleLabel")
                    .font(.largeTitle.bold())
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 12)

            ScrollView {
                filtersView

                Group {
                    if productManager.isLoading {
                        ProgressView()
                            .padding(.top, 24)

                    } else if filteredReviews.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "text.bubble")
                                .font(.system(size: 42))
                                .foregroundColor(.gray.opacity(0.7))

                            Text("reviewsEmptyLabel")
                                .font(.title3.weight(.semibold))
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 34)
                        .padding(.horizontal, 20)

                    } else {
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(filteredReviews, id: \.id) { review in
                                ReviewCard(review: review)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                    }
                }
            }
        }
        .background(Color.white)
        .task {
            await productManager.loadReviews(for: productId)
        }
    }

    private var filtersView: some View {
        HStack(spacing: 12) {
            Picker(LocalizedStringKey("ratingFilterLabel"), selection: $selectedRating) {
                ForEach(ratingOptions, id: \.self) { option in
                    Text(LocalizedStringKey(option)).tag(option)
                }
            }
            .tint(.gray)
            .pickerStyle(.menu)
            .frame(maxWidth: .infinity)

            Picker(LocalizedStringKey("sortFilterLabel"), selection: $selectedSort) {
                ForEach(sortOptions, id: \.self) { option in
                    Text(LocalizedStringKey(option)).tag(option)
                }
            }
            .tint(.gray)
            .pickerStyle(.menu)
            .frame(maxWidth: .infinity)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.25), lineWidth: 1)
        )
        .padding(.horizontal, 20)
        .padding(.top, 6)
    }

    private var filteredReviews: [Review] {
        let filtered: [Review] = {
            switch selectedRating {
            case "fiveStarsOption":
                return productManager.reviews.filter { ($0.rating ?? 0) == 5 }
            case "fourStarsOption":
                return productManager.reviews.filter { ($0.rating ?? 0) == 4 }
            case "threeOrBelowOption":
                return productManager.reviews.filter { ($0.rating ?? 0) <= 3 }
            default:
                return productManager.reviews
            }
        }()

        let sorted: [Review] = {
            switch selectedSort {
            case "sortOldestOption":
                return filtered.sorted { ($0.createdAt ?? "") < ($1.createdAt ?? "") }
            case "sortRatingHighOption":
                return filtered.sorted { ($0.rating ?? 0) > ($1.rating ?? 0) }
            case "sortRatingLowOption":
                return filtered.sorted { ($0.rating ?? 0) < ($1.rating ?? 0) }
            default:
                return filtered.sorted { ($0.createdAt ?? "") > ($1.createdAt ?? "") }
            }
        }()

        return sorted
    }
}
