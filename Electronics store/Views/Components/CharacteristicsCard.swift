import SwiftUI

struct CharacteristicsCard: View {
    // Характеристики оставляем без локализации
    let characteristics: [(title: String, value: String)] = [
        ("Процессор", "M3"),
        ("Оперативная память", "16 ГБ"),
        ("SSD", "256 ГБ"),
        ("Графика", "Apple GPU 10-core"),
        ("Экран", "14\" Retina"),
        ("Аккумулятор", "20 часов"),
        ("Камера", "1080p FaceTime HD"),
        ("ОС", "macOS Sequoia")
    ]
    
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Заголовок (локализуем)
            Text("mainCharacteristicsTitleLabel")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.gray)
            
            Divider()
            
            // Список характеристик
            VStack(spacing: 10) {
                ForEach(displayedCharacteristics, id: \.title) { item in
                    HStack {
                        Text(item.title + ":")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.gray)
                        Spacer()
                        Text(item.value)
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.gray)
                    }
                }
            }
            .animation(.easeInOut(duration: 0.3), value: isExpanded)
            
            // Кнопка "показать больше / свернуть"
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.gray.opacity(0.8))
                        .padding(.top, 6)
                    Spacer()
                }
                // Для VoiceOver и локализации
                .accessibilityLabel(Text(isExpanded ? "showLessButtonLabel" : "showMoreButtonLabel"))
            }
            .buttonStyle(.plain)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .gray.opacity(0.25), radius: 8, x: 0, y: 4)
        )
    }
    
    // Отображаем первые 4 пункта, если карточка свернута
    private var displayedCharacteristics: ArraySlice<(title: String, value: String)> {
        isExpanded ? characteristics[0..<characteristics.count] : characteristics.prefix(4)
    }
}

#Preview {
    CharacteristicsCard()
        .padding()
        .background(Color(.systemGroupedBackground))
}
