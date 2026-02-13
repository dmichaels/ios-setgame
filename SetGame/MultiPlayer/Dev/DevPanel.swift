import SwiftUI

public extension MultiPlayer {

    public struct DevPanel: View {

        @ObservedObject var table: Table
        @ObservedObject var settings: Settings;

        var margin: Int = 10;
        var background: Color = Color(hex: 0x8BD2CC);
        let horizontalPadding: Int = 10;
        let separationPadding: Int = 10;

        public var body: some View {
            Spacer().frame(height: CGFloat(margin))
            AnyDevPanel(table: table, settings: settings) {
                HStack(spacing: CGFloat(separationPadding)) {
                    Text("Hello, world!")
                    Text("ABC")
                    Text("DEV")
                }
                .padding(.horizontal, CGFloat(horizontalPadding))
            }
        }
    }
}

private struct AnyDevPanel<Content: View>: View {

    @ObservedObject var table: Table
    @ObservedObject var settings: Settings

    let background: Color = Color(hex: 0x8BD2CC);

    private let content: Content

    public init(
        table: Table,
        settings: Settings,
        @ViewBuilder content: () -> Content
    ) {
        self.table = table
        self.settings = settings
        self.content = content()
    }

    public var body: some View {
        HStack(spacing: 8) {
            Spacer()
            HStack(alignment: .firstTextBaseline) {
                content
                Spacer()
            }
            .background(
                RoundedRectangle(cornerRadius: 11, style: .continuous)
                    .fill(background)
                    .opacity(0.8)
                    .frame(height: 35)
                    .shadow(color: .black.opacity(0.3),
                            radius: 4, x: 3, y: 6)
            )
            Spacer()
        }
    }
}
