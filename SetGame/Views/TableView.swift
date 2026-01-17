import SwiftUI

public struct TableView: View {

    @EnvironmentObject var table: Table
    @EnvironmentObject var settings: Settings
    @EnvironmentObject var feedback: Feedback

    let statusResetToken: Int

    public var body: some View {
        TableUI(table: table, settings: settings, feedback: feedback, statusResetToken: statusResetToken)
    }
}
