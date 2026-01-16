import SwiftUI

struct CharacteristicsCard: View {

    let characteristics: [(title: String, value: String)]
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            Text("mainCharacteristicsTitleLabel")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.gray)

            Divider()

            VStack(spacing: 10) {
                ForEach(Array(displayedCharacteristics.enumerated()), id: \.offset) { _, item in
                    HStack {
                        Text("\(item.title):")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.gray)

                        Spacer()

                        Text(item.value)
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.gray)
                    }
                }
            }
            .animation(.easeInOut, value: isExpanded)

            if characteristics.count > 4 {
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        isExpanded.toggle()
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
    }

    private var displayedCharacteristics: ArraySlice<(title: String, value: String)> {
        isExpanded ? characteristics[...]
                   : characteristics.prefix(4)
    }
}
