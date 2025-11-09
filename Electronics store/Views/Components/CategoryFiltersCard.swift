import SwiftUI

struct CategoryFiltersCard: View {
    @State private var isExpanded = false
    
    // Фильтры остаются на русском (без локализации)
    let filters: [(title: String, options: [String])] = [
        ("Процессор", ["M1", "M2", "M3", "M4"]),
        ("Оперативная память", ["8 ГБ", "16 ГБ", "32 ГБ"]),
        ("SSD", ["256 ГБ", "512 ГБ", "1 ТБ"]),
        ("Графика", ["8-core", "10-core", "12-core"]),
        ("Экран", ["13\"", "14\"", "16\""]),
        ("Аккумулятор", ["10 ч", "20 ч", "30 ч"]),
        ("Камера", ["720p", "1080p"]),
        ("Цвет", ["Серый", "Чёрный", "Серебристый"])
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // Заголовок локализован
            Text("filtersTitleLabel")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.gray)
            
            Divider()
            
            // Список фильтров
            VStack(spacing: 14) {
                ForEach(displayedFilters, id: \.title) { filter in
                    HStack {
                        Text(filter.title + ":")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.gray)
                        Spacer()
                        
                        Picker(filter.title, selection: .constant(filter.options.first ?? "")) {
                            ForEach(filter.options, id: \.self) { option in
                                Text(option).tag(option)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(.gray)
                        .frame(width: 140)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.1))
                        )
                    }
                }
            }
            .animation(.easeInOut(duration: 0.3), value: isExpanded)
            
            // Кнопка показать больше/меньше (иконка не локализуется, но подпись можно добавить)
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
    
    // Показывать первые 4 фильтра, если свернуто
    private var displayedFilters: [(title: String, options: [String])] {
        isExpanded ? filters : Array(filters.prefix(4))
    }
}

#Preview {
    CategoryFiltersCard()
}
