import SwiftUI

struct CreateReviewScreen: View {

    @Environment(\.dismiss) private var dismiss

    let productId: String
    let productName: String

    @EnvironmentObject private var userManager: UserManager
    @StateObject private var productManager = ProductManager()

    @State private var rating: Int = 0
    @State private var reviewText: String = ""

    @State private var isSending = false
    @State private var showNeedAuthAlert = false
    @State private var showErrorAlert = false
    @State private var errorText = ""

    @State private var myReviewLoaded = false
    @State private var hasMyReview = false

    var body: some View {
        VStack(spacing: 0) {

            HStack {
                Text("writeReviewTitle")
                    .font(.largeTitle.bold())
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)

            ScrollView {
                VStack(spacing: 24) {

                    VStack(spacing: 10) {
                        Text(productName)
                            .font(.largeTitle.bold())
                            .multilineTextAlignment(.center)

                        Text("userRatingLabel")
                            .font(.headline)

                        HStack(spacing: 10) {
                            ForEach(1...5, id: \.self) { star in
                                Image(systemName: star <= rating ? "star.fill" : "star")
                                    .font(.system(size: 32))
                                    .foregroundColor(.yellow)
                                    .onTapGesture { rating = star }
                                    .animation(.easeInOut, value: rating)
                            }
                        }
                    }
                    .padding(.horizontal, 20)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("yourReviewLabel")
                            .font(.headline)

                        TextEditor(text: $reviewText)
                            .padding(12)
                            .frame(height: 180)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white)
                                    .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.25), lineWidth: 1)
                            )
                    }
                    .padding(.horizontal, 20)

                    Button(action: submitReview) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.blue)
                                .frame(height: 52)

                            Text(isSending ? "sendingLabel" : (hasMyReview ? "updateReviewButton" : "submitReviewButton"))
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 20)
                    .disabled(isSending || rating == 0 || reviewText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .opacity((isSending || rating == 0 || reviewText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) ? 0.5 : 1)

                    if hasMyReview {
                        Button(action: deleteReview) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.red)
                                    .frame(height: 52)

                                Text("deleteReviewButton")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 20)
                        .disabled(isSending)
                        .opacity(isSending ? 0.5 : 1)
                    }
                }
                .padding(.top, 18)
                .padding(.bottom, 24)
            }
        }
        .background(Color.white)
        .task {
            await preloadMyReviewIfPossible()
        }
        .alert("needAuthTitle", isPresented: $showNeedAuthAlert) {
            Button("okButton", role: .cancel) {}
        }
        .alert("errorTitle", isPresented: $showErrorAlert) {
            Button("okButton", role: .cancel) {}
        } message: {
            Text(errorText)
        }
    }

    private func preloadMyReviewIfPossible() async {
        guard !myReviewLoaded else { return }
        myReviewLoaded = true

        guard let token = userManager.accessToken, !token.isEmpty else { return }

        if userManager.userId.isEmpty {
            userManager.getMe()
            try? await Task.sleep(nanoseconds: 150_000_000)
        }

        let myId = userManager.userId
        guard !myId.isEmpty else { return }

        if let my = await productManager.loadMyReviewByUserId(productId: productId, myUserId: myId) {
            rating = my.rating ?? 0
            reviewText = my.text ?? ""
            hasMyReview = true
        } else {
            hasMyReview = false
        }
    }

    private func submitReview() {
        guard let token = userManager.accessToken, !token.isEmpty else {
            showNeedAuthAlert = true
            return
        }

        let cleanText = reviewText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard rating >= 1, rating <= 5, !cleanText.isEmpty else { return }

        isSending = true

        Task {
            do {
                _ = try await productManager.submitReview(
                    productId: productId,
                    rating: rating,
                    text: cleanText,
                    accessToken: token
                )

                isSending = false
                hasMyReview = true
                dismiss()

            } catch {
                isSending = false

                if let apiError = error as? ProductManager.ReviewAPIError {
                    switch apiError {
                    case .badStatus(let code) where code == 500:
                        errorText = "Заказ не завершен"
                    default:
                        errorText = apiError.errorDescription ?? "unknownError"
                    }
                } else {
                    errorText = "unknownError"
                }

                showErrorAlert = true
            }
        }
    }

    private func deleteReview() {
        guard let token = userManager.accessToken, !token.isEmpty else {
            showNeedAuthAlert = true
            return
        }

        isSending = true

        Task {
            do {
                try await productManager.deleteMyReview(productId: productId, accessToken: token)

                rating = 0
                reviewText = ""
                hasMyReview = false

                isSending = false
                dismiss()

            } catch {
                isSending = false
                errorText = "unknownError"
                showErrorAlert = true
            }
        }
    }
}
