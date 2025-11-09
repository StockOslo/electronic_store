import SwiftUI

struct ReviewsScreen: View {
    @State private var selectedRating = "allRatingsOption"
    @State private var selectedSort = "sortNewestOption"
    
    private let ratingOptions = [
        "allRatingsOption",
        "fiveStarsOption",
        "fourStarsOption",
        "threeOrBelowOption"
    ]
    
    private let sortOptions = [
        "sortNewestOption",
        "sortOldestOption"
    ]
    
    private let columns = [GridItem(.flexible())]
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 16) {
                
                // Верхняя панель
                HStack(spacing: 12) {
                    Button(action: {}) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.gray)
                            .padding(10)
                            .background(
                                Circle()
                                    .fill(Color.white)
                                    .shadow(color: .gray.opacity(0.3), radius: 4, x: 0, y: 2)
                            )
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                    
                    Text("reviewsTitleLabel")
                        .font(.largeTitle)
                        .bold()
                }
                .padding(.horizontal, 20)
                
                ScrollView {
                    // Блок сортировки
                    HStack(spacing: 12) {
                        Picker("ratingFilterLabel", selection: $selectedRating) {
                            ForEach(ratingOptions, id: \.self) { option in
                                Text(LocalizedStringKey(option))
                                    .tag(option)
                            }
                        }
                        .tint(.gray)
                        .pickerStyle(.menu)
                        .frame(maxWidth: .infinity)
                        
                        Picker("sortFilterLabel", selection: $selectedSort) {
                            ForEach(sortOptions, id: \.self) { option in
                                Text(LocalizedStringKey(option))
                                    .tag(option)
                            }
                        }
                        .tint(.gray)
                        .pickerStyle(.menu)
                        .frame(maxWidth: .infinity)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.05))
                            .shadow(color: .gray.opacity(0.1), radius: 4, x: 0, y: 2)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                    
                    // Карточки отзывов
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(0..<10, id: \.self) { _ in
                            ReviewCard()
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                }
            }
            .ignoresSafeArea(edges: .bottom)
            .background(Color(.systemGroupedBackground))
        }
    }
}

#Preview {
    ReviewsScreen()
}
