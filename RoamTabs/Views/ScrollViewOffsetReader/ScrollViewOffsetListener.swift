import SwiftUI

struct ScrollViewOffsetListenerModifier: ViewModifier {
    let perform: (CGFloat) -> Void
    
    func body(content: Content) -> some View {
        content
            .onPreferenceChange(
                OffsetPreferenceKey.self,
                perform: self.perform
            )
    }
}

extension View {
    func scrollViewOffsetListener(
        perform: @escaping (CGFloat) -> Void
    ) -> some View {
        modifier(
            ScrollViewOffsetListenerModifier(perform: perform)
        )
    }
}
