import SwiftUI
import AudioToolbox
import CoreHaptics
import AVFoundation

public class Feedback: ObservableObject
{
    public var haptics: Bool = false;
    public var sounds: Bool = false;

    public static let TAP: SystemSoundID = 1104;
    public static let CANCEL: SystemSoundID = 1112;
    public static let SWOOSH: SystemSoundID = 1001;

    private var haptic: UIImpactFeedbackGenerator? = nil;

    public init(sounds: Bool = false, haptics: Bool = false) {
        self.sounds = sounds
        self.haptics = haptics
    }

    private func configure() {
        if (self.haptic == nil) {
            do {
                self.haptic = UIImpactFeedbackGenerator(style: .light);
                haptic?.prepare();
                let session: AVAudioSession = AVAudioSession.sharedInstance()
                try session.setCategory(.playback, mode: .default, options: [.mixWithOthers]);
                try session.setActive(true);
            } catch {}
        }
    }
    
    public func triggerHaptic() {
        if (self.haptics) {
            self.configure();
            self.haptic?.impactOccurred();
        }
    }

    public func triggerSound(_ sound: SystemSoundID) {
        if (self.sounds) {
            self.configure();
            AudioServicesPlaySystemSound(sound);
        }
    }

    public func trigger(_ sound: SystemSoundID = Feedback.TAP) {
        self.triggerSound(sound);
        self.triggerHaptic();
    }
}
