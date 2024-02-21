import SwiftUI

struct CardContextMenu: View {
    let isMenuVisible: Bool
    
    var body: some View {
        if isMenuVisible {
            Rectangle()
                .foregroundStyle(.clear)
                .contentShape(Rectangle())
                .frame(maxWidth: .infinity)
                .frame(height: 250)
                .overlay(alignment: .bottomTrailing) {
                    self.menuContent
                }
        }
    }
    
    @ViewBuilder
    var menuContent: some View {
        VStack(alignment: .leading, spacing: 24) {

//            Button(action: {
//                
//            }, label: {
                HStack {
                    Text("Close Tab")
                    
                    Spacer()
                    
                    Image(systemName: "trash")
                }
//            })
        
//            Button(action: {
//                
//            }, label: {
                HStack {
                    Text("Close All Tabs")
                    
                    Spacer()
                    
                    Image(systemName: "trash")
                }
//            })
        }
        .foregroundStyle(.foreground)
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16.0))
        .frame(maxWidth: 200)
    }
}

#Preview {
    CardContextMenu(isMenuVisible: true)
}
