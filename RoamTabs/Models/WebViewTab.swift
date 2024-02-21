import SwiftUI

struct WebViewTab: Identifiable {
    let id: UUID = .init()
    
    let color: Color
    
    var lastViewed: Date = .now
    
    var title: String {
        self.color.description
    }
}
