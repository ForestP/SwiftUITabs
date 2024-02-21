import SwiftUI

struct RootView: View {
    
    @State
    var selectedTab: WebViewTab?
    
    @State
    var tabs: [WebViewTab] = Self.baseColors.map({
        WebViewTab(color: $0)
    })
    
    @State
    var bottomTabId: UUID?
    
    var body: some View {
        TabsView(
            tabs: self.$tabs,
            bottomTabId: self.$bottomTabId
        ) { selectedTab in
            withAnimation {
                self.selectedTab = selectedTab
            }
        }
        .onTapGesture {
            guard self.selectedTab != nil else { return }
            
            withAnimation {
                self.selectedTab = nil
            }
        }
        // MARK: - New Tab Button
        .overlay(alignment: .bottom) {
            Button(action: {
                guard 
                    let color = Self.baseColors.randomElement()
                else {
                    return
                }
                
                let tab = WebViewTab(color: color)
                
                withAnimation {
                    self.tabs.append(tab)
                    self.bottomTabId = tab.id
                }
            }, label: {
                Text("New Tab")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
            })
            .foregroundStyle(.foreground.opacity(0.8))
            .background(.thinMaterial)
            .clipShape(Capsule())
        }
        .overlay {
            GeometryReader { reader in
                Rectangle()
                    .foregroundStyle(.clear)
                    .offset(
                        y: self.selectedTab == nil ? -(reader.size.height + reader.safeAreaInsets.top) : 0
                    )
                    .overlay(content: {
                        self.selectedTab?.color
                            .overlay(alignment: .bottom, content: {
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

                            })
                            .clipShape(UnevenRoundedRectangle(
                                cornerRadii: .init(
                                    bottomLeading: 45.0,
                                    bottomTrailing: 45.0
                                ),
                                style: .continuous
                            ))
                            .transition(.move(edge: .top))
                    })
            }
            .edgesIgnoringSafeArea(.top)
        }
    }
}

extension RootView {
    static let baseColors: [Color] = [
        .red,
        .green,
        .orange,
        .yellow,
        .blue,
    ]
}

#Preview {
    RootView()
}
