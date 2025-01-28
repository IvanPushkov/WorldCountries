
import SwiftUI

struct CustomLoadView: View {
    var body: some View {
        ProgressView()
            .progressViewStyle(.circular)
            .foregroundColor(.gray)
            .scaleEffect(2)
    }
}
