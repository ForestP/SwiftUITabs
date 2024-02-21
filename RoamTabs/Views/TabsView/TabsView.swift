import SwiftUI

struct TabsView: View {
    
    @State
    var offset: CGFloat = 0.0
    
    @State
    var isClosingTab: Bool = false
    
    @Binding
    var tabs: [WebViewTab]
    
    @Binding
    var bottomTabId: UUID?
    
    let selectTab: (WebViewTab) -> Void
    
    
    var body: some View {
        GeometryReader { geometryReader in
            ScrollView {
                VStack {
                    Rectangle()
                        .frame(height: Self.topSpacerHeight)
                        .contentShape(Rectangle())
                        .foregroundStyle(.clear)
                        .allowsHitTesting(false)
                    
                    ForEach(
                        Array(self.tabs.enumerated()),
                        id: \.element.id
                    ) {
                        index,
                        tab in
                        
                        TabCardView(
                            tab: tab,
                            cardSpacing: self.cardSpacing,
                            depthOffset: self.depthOffset(
                                for: index,
                                in: geometryReader.size
                            ),
                            angle: self.angle(
                                for: index,
                                in: geometryReader.size
                            ),
                            closeTab: { self.closeTab(at: index) },
                            closeAllTabs: { self.tabs = [] }
                        )
                        .onTapGesture {
                            /// Update Tab lastViewed
                            var tab = tab
                            tab.lastViewed = .now
                            
                            /// Present Selcted Tab
                            self.selectTab(tab)
                            
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
                        
                    }
                    
                    Rectangle()
                        .frame(
                            width: geometryReader.size.width,
                            height: Self.bottomSpacerHeight
                        )
                        .contentShape(Rectangle())
                        .foregroundStyle(.clear)
                        .allowsHitTesting(false)
                        .scrollViewOffsetReader(
                            scrollViewHeight: geometryReader.size.height,
                            offset: Self.bottomSpacerHeight
                        )
                }
                .scrollViewOffsetListener(
                    perform: {
                        guard !isClosingTab else {
                            return
                        }
                        
                        self.offset = $0
                    }
                )
            }
            .coordinateSpace(.named("scroll"))
            .defaultScrollAnchor(.bottom)
            .scrollIndicators(.hidden)
            .scrollClipDisabled()
            .background(.purple)
            .scrollPosition(
                id: self.$bottomTabId,
                anchor: .center
            )
        }
    }
    
    func closeTab(at index: Int) {
        self.isClosingTab = true
        
        var newTabs = self.tabs
        newTabs.remove(at: index)
        
        withAnimation {
            self.tabs = newTabs
        } completion: {
            DispatchQueue.main.asyncAfter(
                deadline: .now().advanced(by: .milliseconds(500)
            ), execute: {
                self.isClosingTab = false
            })
        }
        
    }
    
    /// Dynamically Space Tabs
    var cardSpacing: CGFloat {
        switch self.tabs.count {
        case 1:
            250
        case 2...3:
            150
        case 4...5:
            100
        default:
            80
        }
    }
    
    func depthOffset(
        for index: Int,
        in viewBounds: CGSize
    ) -> CGFloat {
        -Self.interpolate(
            min: Self.minBevelOffset,
            max: Self.maxBevelOffset,
            percent: offsetPercentage(
                for: index,
                in: viewBounds
            )
        )
    }
    
    func angle(
        for index: Int,
        in viewBounds: CGSize
    ) -> Angle {
        .degrees(
            -Self.interpolate(
                min: Self.minAngleDegrees,
                max: Self.maxAngleDegrees,
                percent: offsetPercentage(
                    for: index,
                    in: viewBounds
                )
            )
        )
    }
    
    /// Calcuates position of the card at `index`
    /// Relative to the provided viewBounds
    func offsetPercentage(
        for index: Int,
        in viewBounds: CGSize
    ) -> CGFloat {
        let tabsFrameHeight = viewBounds.height - (Self.topSpacerHeight + Self.bottomSpacerHeight)
        
        // The offset for the item based
        // on just its index and height
        let itemBaseOffset = self.cardSpacing * CGFloat(self.tabs.count - index)
        
        // The item offset adjusted for current scroll postion
        let itemOffsetWithScroll = itemBaseOffset + self.offset
        
        // Clip Offset to Frame
        let clippedOffset = max(
            min(itemOffsetWithScroll, tabsFrameHeight),
            0
        )
        
        return 1 - (clippedOffset / tabsFrameHeight)
    }
}

// MARK: - TabsView Constants

extension TabsView {
    // MARK: Spacers
    static let topSpacerHeight: CGFloat = 250
    static let bottomSpacerHeight: CGFloat = 200
    
    // MARK: Angles
    static let maxAngleDegrees: CGFloat = 45
    static let minAngleDegrees: CGFloat = 15
    
    // MARK: Bevel Offset
    static let maxBevelOffset: CGFloat = 2.5
    static let minBevelOffset: CGFloat = 0.5
    
    static func interpolate(
        min: CGFloat,
        max: CGFloat,
        percent: CGFloat
    ) -> CGFloat {
        (percent * (max - min)) + min
    }
}

#Preview {
    TabsView(
        tabs: .constant([
            WebViewTab(color: .red),
            WebViewTab(color: .green),
            WebViewTab(color: .yellow),
            WebViewTab(color: .blue),
            WebViewTab(color: .red),
            WebViewTab(color: .green),
            WebViewTab(color: .yellow),
            WebViewTab(color: .blue),
            WebViewTab(color: .red),
            WebViewTab(color: .green),
            WebViewTab(color: .yellow),
            WebViewTab(color: .blue)
        ]),
        bottomTabId: .constant(nil)
    ) {
        print($0)
    }
}
