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
            bottomTabId: self.$bottomTabId,
            tabTitle: { tab in
                HStack {
                    Circle()
                        .foregroundStyle(tab.color)
                        .frame(width: 16, height: 16)
                    
                    Text(tab.title.capitalized)
                        .font(.headline)
                        .foregroundStyle(.white)
                    
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .padding(2)
            },
            tabContent: {
                RoundedRectangle(cornerRadius: 25.0)
                    .foregroundStyle($0.color)
            },
            selectTab: { selectedTab, index in
                /// Update Tab lastViewed
                var tab = selectedTab
                tab.lastViewed = .now
                
                /// Present Selcted Tab
                withAnimation {
                    self.selectedTab = selectedTab
                }
                
                /// Update Tabs Order
                var tabs = self.tabs
                tabs.remove(at: index)
                tabs.append(tab)
                
                /// Set Updated Tabs After Delay
                /// (Update Behind Presented Tab)
                DispatchQueue.main.asyncAfter(
                    deadline: .now().advanced(by: .milliseconds(500)),
                    execute: { self.tabs = tabs }
                )
            }
        )
        // Dismiss Selected Tab on BG Tap
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
            ActiveTabSheet(
                selectedTab: self.$selectedTab
            ) {
                self.selectedTab?.color
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
