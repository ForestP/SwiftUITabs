import SwiftUI

struct ActiveTabSheet<
    ActiveTab: Identifiable,
    TabContent: View
>: View {
    
    @Binding
    var selectedTab: ActiveTab?
    
    @ViewBuilder
    var tabContent: TabContent
    
    var body: some View {
        GeometryReader { reader in
            Rectangle()
                .foregroundStyle(.clear)
                .overlay(content: {
                    if selectedTab != nil {
                        self.tabContent
                            .overlay(
                                alignment: .bottom,
                                content: { self.closeButton }
                            )
                            .clipShape(UnevenRoundedRectangle(
                                cornerRadii: .init(
                                    bottomLeading: 45.0,
                                    bottomTrailing: 45.0
                                ),
                                style: .continuous
                            ))
                            .transition(.move(edge: .top))
                    }
                })
        }
    }
    
    @ViewBuilder
    var closeButton: some View {
        Button {
            withAnimation {
                self.selectedTab = nil
            }
        } label: {
            Text("Close Tab")
                .fontWeight(.semibold)
        }
        .foregroundStyle(.foreground)
        .padding()
    }
    
}

#Preview {
    ActiveTabSheet(
        selectedTab: .constant(WebViewTab(color: .red)),
        tabContent: {
            Color.blue
        })
    .edgesIgnoringSafeArea(.top)
}
