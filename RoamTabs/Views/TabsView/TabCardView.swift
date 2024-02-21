import SwiftUI

class TabCardDragOffsetModel: ObservableObject {
    @Published
    var dragOffsetX: CGFloat = .zero
    
    
}

struct TabCardView: View {
    var tab: WebViewTab
    var cardSpacing: CGFloat
    
    let depthOffset: CGFloat
    let angle: Angle
    
    let closeTab: () -> Void
    let closeAllTabs: () -> Void
    
    @StateObject
    var offsetViewModel: TabCardDragOffsetModel = .init()
    
    @State
    var transitionEdge: Edge = .bottom
    
    @State
    var isContextMenuPresented: Bool = false
    
    var body: some View {
        Rectangle()
            .contentShape(Rectangle())
            .frame(maxWidth: .infinity)
            .frame(height: self.cardSpacing)
            .background(content: {
                RoundedRectangle(cornerRadius: Self.cardRadius)
                    .foregroundStyle(tab.color)
                    .overlay(content: {
                        RoundedRectangle(cornerRadius: Self.cardRadius)
                            .foregroundStyle(.black.opacity(0.15))
                    })
                    .frame(height: Self.cardTrueHeight)
                    .offset(y: self.depthOffset)
            })
            .offset(x: self.offsetViewModel.dragOffsetX)
            .overlay(content: {
                RoundedRectangle(cornerRadius: Self.cardRadius)
                    .foregroundStyle(tab.color)
                    .frame(maxWidth: .infinity)
                    .frame(height: Self.cardTrueHeight)
                    .offset(x: self.offsetViewModel.dragOffsetX)
                
            })
            .rotation3DEffect(
                self.angle,
                axis: (x: 1.0, y: 0.0, z: 0.0),
                perspective: 0.6
            )
            .rotation3DEffect(
                .degrees(self.offsetViewModel.dragOffsetX / 10),
                axis: (x: 0.0, y: 0.0, z: 1.0)
            )
            .transition(.move(edge: self.transitionEdge))
            // MARK: - Drag Gesture Overlay
            .overlay(content: {
                Rectangle()
                    .foregroundStyle(.clear)
                    .contentShape(Rectangle())
                    .frame(height: Self.cardTrueHeight)
//                    .gesture(
//                        LongPressGesture(
//                            minimumDuration: 1,
//                            maximumDistance: 5.0
//                        ).onEnded({ isPressed in
//                            print("pressed: ", isPressed)
//                            
//
//                            self.isContextMenuPresented = true
//                        })
//                    )
                    .gesture(DragGesture()
                        .onChanged({ gesture in
                            self.offsetViewModel.dragOffsetX = gesture.translation.width
                            
                            switch gesture.translation.width.sign {
                            case .plus:
                                self.transitionEdge = .trailing
                            case .minus:
                                self.transitionEdge = .leading
                            }
                        })
                        .onEnded({ gesture in
                            
                            if abs(self.offsetViewModel.dragOffsetX) > 100 {
                                self.closeTab()
                            }
                            
                            withAnimation {
                                self.offsetViewModel.dragOffsetX = 0
                            }
                            
                    }))
                    .onReceive(
                        self.offsetViewModel.$dragOffsetX.debounce(
                            for: 0.2,
                            scheduler: RunLoop.main
                        )
                    ) { seachTerm in
                        guard !self.offsetViewModel.dragOffsetX.isZero else { return }

                        withAnimation {
                            self.offsetViewModel.dragOffsetX = 0
                        }
                    }
            })
            // MARK: - TabTitle
            .overlay(content: {
                Rectangle()
                    .foregroundStyle(.clear)
                    .contentShape(Rectangle())
                    .frame(height: Self.cardTrueHeight)
                    .overlay(alignment: .topLeading) {
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
                    }
                    .offset(
                        x: self.depthOffset * 4,
                        y: -self.depthOffset * 8
                    )
                    .offset(x: self.offsetViewModel.dragOffsetX )
                    .rotation3DEffect(
                        .degrees(self.offsetViewModel.dragOffsetX / 10),
                        axis: (x: 0.0, y: 0.0, z: 1.0)
                    )
                    .allowsHitTesting(false)
                
            })
            .padding(.horizontal, 80)
        
    }
}

// MARK: - TabCardView Constants
extension TabCardView {
    static let cardTrueHeight: CGFloat = 250
    static let cardRadius: CGFloat = 25.0
}

#Preview {
    TabCardView(
        tab: .init(color: .blue),
        cardSpacing: 100,
        depthOffset: -4 ,
        angle: .degrees(-40),
        closeTab: {
            print("close tab")
        },
        closeAllTabs: {
            print("close all tabs")
        }
    )
}
