import SwiftUI

public struct Space: View {
    var size: CGFloat = 0;
    public var body: some View {
        Spacer(minLength: size)
    }
}
