import SwiftUI

struct GradeCard: View {

    let rating: Double
    let reviewCounts: [Int]  

    init(
        rating: Double = 3.2,
        reviewCounts: [Int] = [120, 80, 40, 20, 10]
    ) {
        self.rating = rating
        self.reviewCounts = Array(reviewCounts.prefix(5)) + Array(repeating: 0, count: max(0, 5 - reviewCounts.count))
    }

    private var maxCount: Int {
        max(reviewCounts.max() ?? 1, 1)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            // Заголовок + средний рейтинг
            HStack {
                Text("ratingLabel")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.gray)

                Spacer()

                HStack(spacing: 4) {
                    ForEach(0..<5, id: \.self) { index in
                        Image(systemName: index < Int(rating.rounded(.down)) ? "star.fill" : "star")
                            .foregroundColor(.yellow)
                            .font(.system(size: 14))
                    }

                    Text(String(format: "%.1f", rating))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }

            Divider()

            // Распределение отзывов
            VStack(spacing: 10) {
                ForEach(0..<5, id: \.self) { index in
                    let stars = 5 - index
                    let count = reviewCounts[index]
                    let progress = CGFloat(count) / CGFloat(maxCount)

                    HStack(spacing: 8) {

                        // ⭐️⭐⭐⭐⭐
                        HStack(spacing: 2) {
                            ForEach(0..<stars, id: \.self) { _ in
                                Image(systemName: "star.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(.yellow)
                            }
                        }
                        .frame(width: 60, alignment: .leading)

                        // Прогресс-бар
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 8)

                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.yellow.opacity(0.85))
                                    .frame(
                                        width: geo.size.width * progress,
                                        height: 8
                                    )
                            }
                        }
                        .frame(height: 8)

                        // Кол-во отзывов
                        Text("\(count)")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                            .frame(width: 36, alignment: .trailing)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        )
    }
}

#Preview {
    GradeCard()
        .padding()
}
