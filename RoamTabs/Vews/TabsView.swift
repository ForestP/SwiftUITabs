import SwiftUI

private struct OffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {}
}

//struct ViewOffsetKey: PreferenceKey {
//    typealias Value = CGFloat
//    static var defaultValue = CGFloat.zero
//    static func reduce(value: inout Value, nextValue: () -> Value) {
//        value += nextValue()
//    }
//}

struct WebviewTab: Identifiable {
    let id: UUID = .init()
    
    let color: Color
}

struct TabsView: View {
    @State
    var tabs: [WebviewTab] = [
        WebviewTab(color: .red),
        WebviewTab(color: .green),
        WebviewTab(color: .yellow),
        WebviewTab(color: .blue),
        //        WebviewTab(color: .red),
        //        WebviewTab(color: .green),
        //        WebviewTab(color: .yellow),
        //        WebviewTab(color: .blue)
    ]
    
    @State
    var offset: CGFloat = 0.0
    
    @State
    var hasTouched: Bool = false
        
    var body: some View {
        GeometryReader { reader in
            ScrollView {
                VStack {
                    
                    Rectangle()
                        .frame(width: .infinity, height: 250)
                        .contentShape(Rectangle())
                        .foregroundStyle(.clear)
                        .allowsHitTesting(false)
                    
                    ForEach(Array(self.tabs.enumerated()), id: \.element.id) { index, tab in
                        CardView(
                            color: tab.color,
                            cardSpacing: self.cardSpacing,
                            depthOffset: { self.depthOffset(for: index) },
                            angle: { self.angle(for: index) }) {
                                self.tabs.remove(at: index)
                            }
                    }
                    
                    Rectangle()
                        .frame(width: .infinity, height: 200)
                        .contentShape(Rectangle())
                        .foregroundStyle(.clear)
                        .allowsHitTesting(false)
                        .overlay(content: {
                            GeometryReader {
                                Color.clear.preference(
                                    key: OffsetPreferenceKey.self,
                                    value: reader.size.height - $0.frame(in: .named("scroll")).origin.y - 100
                                )
                                .onAppear(perform: {
                                    print("bounds: ", reader.size.height)
                                })
                            }
                            .frame(height: 0)
                        })
                    
                   
                }
                .onPreferenceChange(
                    OffsetPreferenceKey.self,
                    perform: self.onOffsetChange
                )
            }
            .coordinateSpace(.named("scroll"))
            .defaultScrollAnchor(.bottom)
            .scrollIndicators(.hidden)
            .scrollClipDisabled()
            .background(.purple)
        }
    }
    
    var cardSpacing: CGFloat {
        switch self.tabs.count {
        case .zero:
            250
        default:
            80
        }
    }
    
    func depthOffset(for index: Int) -> CGFloat {
        let adjustedIndex = CGFloat(index) - self.itemsOffset
        
        return -max(min(adjustedIndex / 1.1, 4), 0)
    }
    
    // TODO: Convert to percentage
    func angle(for index: Int) -> Angle {
        let adjustedIndex = CGFloat(index) - self.itemsOffset
        
        if index == 0 {
            print("index: ", adjustedIndex)
        }
        
        return .degrees(max(min(-adjustedIndex * 7.5, -15), -45))
    }
    
    func onOffsetChange(offset: CGFloat) -> Void {
        print("offset: ", offset)
        self.offset = offset
    }
    
    var itemsOffset: CGFloat {
        self.offset / self.cardSpacing
    }
}

#Preview {
    TabsView()
}
