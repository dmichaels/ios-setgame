import SwiftUI

public struct VersionInfo {

    public static var version: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?";
    }

    public static var build: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "?";
    }

    // To get this commit property to work add the following kind of thing to a new build/run script
    // in Build Phases of Xcode, and move this script before the Compile Sources in the list of phases;
    // also probably make sure the "Based on dependency analysis" check box is turned off.
    //
    // GIT_COMMAND=`xcrun -find git`
    // GIT_COMMIT=`${GIT_COMMAND} rev-parse --short HEAD`
    // PROPERTIES_FILE="${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/BuildInfo.plist"
    // /usr/libexec/PlistBuddy -c "Delete :GitCommit"                      "$PROPERTIES_FILE"
    // /usr/libexec/PlistBuddy -c "Add    :GitCommit string ${GIT_COMMIT}" "$PROPERTIES_FILE"
    // /usr/libexec/PlistBuddy -c "Set    :GitCommit        ${GIT_COMMIT}" "$PROPERTIES_FILE"
    // /usr/libexec/PlistBuddy -c "Print  :GitCommit        ${GIT_COMMIT}" "$PROPERTIES_FILE"
    //
    public static var commit: String {
        guard let path = Bundle.main.path(forResource: "BuildInfo", ofType: "plist"),
              let dictionary = NSDictionary(contentsOfFile: path) as? [String: Any],
              let commit = dictionary["GitCommit"] as? String else {
            return ""
        }
        return commit.uppercased();
    }
}
