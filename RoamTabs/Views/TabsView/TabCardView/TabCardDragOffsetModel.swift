import Combine
import Foundation

class TabCardDragOffsetModel: ObservableObject {
    @Published
    var dragOffsetX: CGFloat = .zero
    
    var debounced: Publishers.Debounce<
        Published<CGFloat>.Publisher,
        RunLoop
    > {
        self.$dragOffsetX.debounce(
            for: .seconds(0.2),
            scheduler: RunLoop.main
        )
    }
}
