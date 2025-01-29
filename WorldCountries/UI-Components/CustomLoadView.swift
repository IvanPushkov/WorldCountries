
import SwiftUI

struct CustomLoadView: View {
    @State var isLoading: Bool
    var body: some View {
        ProgressView()
            .progressViewStyle(.circular)
            .foregroundColor(Color("GrayText"))
            .scaleEffect(2)
            .rotationEffect(Angle(degrees: isLoading ? 360 : 0))
            .animation(.linear(duration: 1).repeatForever(), value: isLoading)
    }
}
