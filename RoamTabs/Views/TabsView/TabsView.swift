import SwiftUI

struct TabsView<
    Tab: Identifiable,
    CardContent: View,
    CardTitle: View
>: View {
    
    @State
    var offset: CGFloat = 0.0
    
    @State
    var isClosingTab: Bool = false
    
    @Binding
    var tabs: [Tab]
    
    @Binding
    var bottomTabId: Tab.ID?
    
    @ViewBuilder
    let tabTitle: (Tab) -> CardTitle
    
    @ViewBuilder
    let tabContent: (Tab) -> CardContent
    
    let selectTab: (Tab, Int) -> Void
    
    var body: some View {
        GeometryReader { geometryReader in
            ScrollView {
                VStack {
                    Rectangle()
                        .frame(height: TabsViewConstants.topSpacerHeight)
                        .contentShape(Rectangle())
                        .foregroundStyle(.clear)
                        .allowsHitTesting(false)
                    
                    ForEach(
                        Array(self.tabs.enumerated()),
                        id: \.element.id
                    ) { index, tab in
                        
                        TabCardView(
                            cardSpacing: self.cardSpacing,
                            depthOffset: self.depthOffset(
                                for: index,
                                in: geometryReader.size
                            ),
                            angle: self.angle(
                                for: index,
                                in: geometryReader.size
                            ),
                            title: { self.tabTitle(tab) },
                            content: { self.tabContent(tab) },
                            closeTab: { self.closeTab(at: index) },
                            closeAllTabs: { self.tabs = [] }
                        )
                        .onTapGesture { self.selectTab(tab, index) }
                    }
                    
                    Rectangle()
                        .frame(
                            width: geometryReader.size.width,
                            height: TabsViewConstants.bottomSpacerHeight
                        )
                        .contentShape(Rectangle())
                        .foregroundStyle(.clear)
                        .allowsHitTesting(false)
                        .scrollViewOffsetReader(
                            scrollViewHeight: geometryReader.size.height,
                            offset: TabsViewConstants.bottomSpacerHeight
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
        guard newTabs.indices.contains(index) else {
            return
        }
        
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
            min: TabsViewConstants.minBevelOffset,
            max: TabsViewConstants.maxBevelOffset,
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
                min: TabsViewConstants.minAngleDegrees,
                max: TabsViewConstants.maxAngleDegrees,
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
        let tabsFrameHeight = viewBounds.height - (
            TabsViewConstants.topSpacerHeight + TabsViewConstants.bottomSpacerHeight
        )
        
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
    
    static func interpolate(
        min: CGFloat,
        max: CGFloat,
        percent: CGFloat
    ) -> CGFloat {
        (percent * (max - min)) + min
    }
}

// MARK: - TabsView Constants

struct TabsViewConstants {
    // MARK: Spacers
    static let topSpacerHeight: CGFloat = 250
    static let bottomSpacerHeight: CGFloat = 200
    
    // MARK: Angles
    static let maxAngleDegrees: CGFloat = 45
    static let minAngleDegrees: CGFloat = 15
    
    // MARK: Bevel Offset
    static let maxBevelOffset: CGFloat = 2.5
    static let minBevelOffset: CGFloat = 0.5
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
        bottomTabId: .constant(nil),
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
        selectTab: {
            print("did select: ", $0.title, $1)
        }
    )
}
