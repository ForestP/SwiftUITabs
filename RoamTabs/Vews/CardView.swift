import SwiftUI

struct CardView: View {
    var color: Color
    var cardSpacing: CGFloat
    
    let depthOffset: () -> CGFloat
    let angle: () -> Angle
    let removeCard: () -> Void
    
    @State
    var dragOffsetX: CGFloat = .zero
    
    var body: some View {
        Rectangle()
            .foregroundStyle(.black)
            .contentShape(Rectangle())
            .frame(
                width: .infinity,
                height: self.cardSpacing
            )
            .background(content: {
                RoundedRectangle(cornerRadius: 25.0)
                    .foregroundStyle(color)
                    .overlay(content: {
                        RoundedRectangle(cornerRadius: 25.0)
                            .foregroundStyle(.black.opacity(0.15))
                    })
                    .frame(
                        height: 250
                    )
                    .offset(y: self.depthOffset())
            })
            .offset(x: self.dragOffsetX)
            .overlay(content: {
                RoundedRectangle(cornerRadius: 25.0)
                    .foregroundStyle(color)
                    .frame(width: .infinity, height: 250)
                    .offset(x: self.dragOffsetX)
                    .gesture(DragGesture(coordinateSpace: .global)
                        .onChanged({ gesture in
                            print("gesture")
                            self.dragOffsetX = gesture.translation.width
                        })
                        .onEnded({ gesture in
                            withAnimation {
                                print("on end")
                                if abs(self.dragOffsetX) > 20 {
                                    print("remove card")
                                    self.removeCard()
                                }
                                
                                self.dragOffsetX = 0
                            }
                            
                        })
                    )
            })
            .rotation3DEffect(
                self.angle(),
                axis: (x: 1.0, y: 0.0, z: 0.0),
                perspective: 0.6
            )
            .rotation3DEffect(
                .degrees(self.dragOffsetX / 10),
                axis: (x: 0.0, y: 0.0, z: 1.0)
            )
            .padding(.horizontal, 80)
            .transition(.move(edge: .leading))
            
    }
}

#Preview {
    CardView(
        color: .blue,
        cardSpacing: 100,
        depthOffset: { 100 },
        angle: { .degrees(-40)},
        removeCard: {
            print("did remove card")
        }
    )
}
