import SwiftUI

struct ScrollViewOffsetReader: View {
    
    let scrollViewHeight: CGFloat
    let offset: CGFloat
    
    init(
        scrollViewHeight: CGFloat,
        offset: CGFloat = .zero
    ) {
        self.scrollViewHeight = scrollViewHeight
        self.offset = offset
    }
    
    var body: some View {
        GeometryReader {
            Color.clear.preference(
                key: OffsetPreferenceKey.self,
                value: self.scrollViewHeight - $0.frame(in: .named("scroll")).origin.y - self.offset
            )
        }
    }
}


struct ScrollViewOffsetReaderModifier: ViewModifier {
    let scrollViewHeight: CGFloat
    let offset: CGFloat
    
    func body(content: Content) -> some View {
         content
            .overlay {
                ScrollViewOffsetReader(
                    scrollViewHeight: self.scrollViewHeight,
                    offset: self.offset
                )
            }
     }
}

extension View {
    func scrollViewOffsetReader(
        scrollViewHeight: CGFloat,
        offset: CGFloat
    ) -> some View {
        modifier(ScrollViewOffsetReaderModifier(
            scrollViewHeight: scrollViewHeight,
            offset: offset
        ))
    }
}

#Preview {
    ScrollViewOffsetReader(
        scrollViewHeight: 800
    )
}
