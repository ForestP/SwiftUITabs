import Combine
import SwiftUI

struct TabCardView<
    Title: View,
    Content: View
>: View {
    @StateObject
    var offsetViewModel: TabCardDragOffsetModel = .init()
    
    @State
    var transitionEdge: Edge = .bottom
    
    let angle: Angle
    var cardSpacing: CGFloat
    let depthOffset: CGFloat
    let visibleCardHeight: CGFloat
    
    let closeTab: () -> Void
    let closeAllTabs: () -> Void
    
    @ViewBuilder
    let title: Title
    
    @ViewBuilder
    let content: Content
    
    init(
        cardSpacing: CGFloat,
        depthOffset: CGFloat,
        angle: Angle,
        visibleCardHeight: CGFloat = 250,
        @ViewBuilder title: @escaping () -> Title,
        @ViewBuilder content: @escaping () -> Content,
        closeTab: @escaping () -> Void,
        closeAllTabs: @escaping () -> Void
    ) {
        self.cardSpacing = cardSpacing
        self.depthOffset = depthOffset
        self.angle = angle
        self.visibleCardHeight = visibleCardHeight
        self.closeTab = closeTab
        self.closeAllTabs = closeAllTabs
        self.title = title()
        self.content = content()
    }
    
    var body: some View {
        Rectangle()
            .foregroundStyle(.clear)
            .contentShape(Rectangle())
            .frame(maxWidth: .infinity)
            .frame(height: self.cardSpacing)
            .background(content: {
                self.content
                    .overlay(content: {
                        Color.black
                            .opacity(0.15)
                            .mask(self.content)
                    })
                    .frame(height: self.visibleCardHeight)
                    .offset(y: self.depthOffset)
            })
            .offset(x: self.offsetViewModel.dragOffsetX)
            .overlay(content: {
                self.content
                    .frame(maxWidth: .infinity)
                    .frame(height: self.visibleCardHeight)
                    .offset(x: self.offsetViewModel.dragOffsetX)
                
            })
            /// Parallax Rotation
            .rotation3DEffect(
                self.angle,
                axis: (x: 1.0, y: 0.0, z: 0.0),
                perspective: 0.6
            )
            /// Dismiss Swipe Rotation
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
                    .frame(height: self.visibleCardHeight)
                    .gesture(
                        DragGesture()
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
                                
                                if abs(self.offsetViewModel.dragOffsetX) > 60 {
                                    self.closeTab()
                                }
                                
                                withAnimation {
                                    self.offsetViewModel.dragOffsetX = 0
                                }
                            
                            })
                    )
                    .onReceive(self.offsetViewModel.debounced) { seachTerm in
                        guard !self.offsetViewModel.dragOffsetX.isZero else {
                            return
                        }

                        withAnimation {
                            self.offsetViewModel.dragOffsetX = 0
                        }
                    }
            })
            // MARK: - Card Title
            .overlay(content: {
                Rectangle()
                    .foregroundStyle(.clear)
                    .contentShape(Rectangle())
                    .frame(height: self.visibleCardHeight)
                    .overlay(alignment: .topLeading) {
                        self.title
                    }
                    .offset(
                        x: self.depthOffset * 4,
                        y: -self.depthOffset * 8
                    )
                    .offset(x: self.offsetViewModel.dragOffsetX * 1.2 )
                    .rotation3DEffect(
                        .degrees(self.offsetViewModel.dragOffsetX / 10),
                        axis: (x: 0.0, y: 0.0, z: 1.0)
                    )
                    .allowsHitTesting(false)
                
            })
            .padding(.horizontal, 80)
        
    }
}

#Preview {
    TabCardView(
        cardSpacing: 100,
        depthOffset: -4,
        angle: .degrees(-40),
        title: {
            Text("Title")
                .padding(.horizontal)
                .foregroundStyle(.white)
                .fontWeight(.semibold)
        },
        content: {
            RoundedRectangle(cornerRadius: 25.0)
                .foregroundStyle(.blue)
        },
        closeTab: {
            print("close tab")
        },
        closeAllTabs: {
            print("close all tabs")
        }
    )
}
