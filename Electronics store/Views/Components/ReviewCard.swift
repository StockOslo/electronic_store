import SwiftUI

struct ReviewCard: View {

    let review: Review
    @EnvironmentObject private var userManager: UserManager

    private var displayName: String {
        if let uid = review.userId, !uid.isEmpty, uid == userManager.userId {
            return "Вы"
        }
        return "Пользователь"
    }

    private var dateText: String {
        review.createdAt ?? ""
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {

            HStack(spacing: 12) {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 42, height: 42)
                    .foregroundColor(.gray)

                VStack(alignment: .leading, spacing: 2) {
                    Text(displayName)
                        .font(.system(size: 16, weight: .semibold))

                    Text(dateText)
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }

                Spacer()
            }

            HStack(spacing: 3) {
                let r = review.rating ?? 0
                ForEach(0..<5, id: \.self) { i in
                    Image(systemName: i < r ? "star.fill" : "star")
                        .foregroundColor(.yellow)
                        .font(.caption)
                }
            }

            Text(review.text ?? "")
                .font(.system(size: 15))
                .foregroundColor(.secondary)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(radius: 4)
        )
    }
}
