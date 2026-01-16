import SwiftUI

struct BagsProductCard: View {

    @EnvironmentObject private var cartManager: CartManager

    let product: Product
    let imageURLs: [String]

    let maxValue: Int = 99

    @State private var selectedImageIndex = 0
    @State private var updateTask: Task<Void, Never>? = nil
    @State private var localQuantity: Int = 0

    private var productName: String { product.name }

    private func priceText(_ raw: String) -> String {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)

        let allowed = CharacterSet(charactersIn: "0123456789., ")
        let filtered = String(trimmed.unicodeScalars.filter { allowed.contains($0) })
        let noSpaces = filtered.replacingOccurrences(of: " ", with: "")
        let normalized = noSpaces.replacingOccurrences(of: ",", with: ".")

        if let value = Double(normalized) {
            return String(format: "%.2f ₽", value)
        }
        return "\(trimmed) ₽"
    }

    private var displayImages: [String] {
        imageURLs.isEmpty ? ["laptopcomputer", "laptopcomputer", "laptopcomputer"] : imageURLs
    }

    private var isRemoteImages: Bool {
        !(imageURLs.isEmpty)
    }

    var body: some View {
        HStack(spacing: 8) {

            VStack(alignment: .leading, spacing: 8) {

                TabView(selection: $selectedImageIndex) {
                    ForEach(displayImages.indices, id: \.self) { index in
                        if isRemoteImages {
                            AsyncImage(url: URL(string: displayImages[index])) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .padding()
                                default:
                                    Image(systemName: "photo")
                                        .resizable()
                                        .scaledToFit()
                                        .padding()
                                        .foregroundStyle(.gray)
                                }
                            }
                            .tag(index)
                        } else {
                            Image(systemName: displayImages[index])
                                .resizable()
                                .scaledToFit()
                                .padding()
                                .foregroundStyle(.blue)
                                .tag(index)
                        }
                    }
                }
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                .frame(height: 140)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 4)
                )

                Text(productName)
                    .font(.headline)
                    .lineLimit(2)
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            VStack(alignment: .leading, spacing: 8) {

                Text(priceText(product.price))
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.blue)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)

                HStack(spacing: 20) {

                    Button {
                        guard cartManager.isAuthorized else { return }
                        let newQty = max(localQuantity - 1, 0)
                        localQuantity = newQty
                        scheduleQuantityUpdate(newQty)
                    } label: {
                        Image(systemName: "minus")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(Color.blue)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)

                    Text("\(localQuantity)")
                        .font(.system(size: 20, weight: .medium))
                        .frame(width: 40)
                        .multilineTextAlignment(.center)

                    Button {
                        guard cartManager.isAuthorized else { return }
                        guard localQuantity < maxValue else { return }
                        let newQty = localQuantity + 1
                        localQuantity = newQty
                        scheduleQuantityUpdate(newQty)
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(Color.blue)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.blue.opacity(0.05))
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .gray.opacity(0.2), radius: 8, x: 0, y: 4)
        )
        .onAppear {
            localQuantity = max(cartManager.quantity(for: product.id), 0)
        }
        .onChange(of: cartManager.quantity(for: product.id)) { newValue in
            localQuantity = max(newValue, 0)
        }
        .onDisappear { updateTask?.cancel() }
    }

    private func scheduleQuantityUpdate(_ newQty: Int) {
        updateTask?.cancel()
        updateTask = Task {
            try? await Task.sleep(nanoseconds: 180_000_000)
            await cartManager.setQuantity(productId: product.id, quantity: newQty)
        }
    }
}
