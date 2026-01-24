import SwiftUI
import AudioToolbox
import CoreHaptics
import AVFoundation

public class Feedback: ObservableObject
{
    public var haptics: Bool = false;
    public var sounds: Bool = false;

    public static let CLICK: SystemSoundID = 1104;
    public static let CANCEL: SystemSoundID = 1112;
    public static let CHIME: SystemSoundID  = 1370;
    public static let SWOOSH: SystemSoundID = 1001;
    public static let BADING: SystemSoundID = 1253;

    public static let TAP: SystemSoundID    = Feedback.CLICK;
    public static let NEW: SystemSoundID    = Feedback.BADING;
    public static let SET: SystemSoundID    = Feedback.CHIME;
    public static let NOSET: SystemSoundID  = Feedback.CANCEL;

    public static let HAPTIC_TAP: Int   = 1;
    public static let HAPTIC_NOSET: Int = 2;

    private var haptic: UIImpactFeedbackGenerator? = nil;
    private var hapticUIKit: UINotificationFeedbackGenerator? = nil;

    public init(sounds: Bool = false, haptics: Bool = false) {
        self.sounds = sounds
        self.haptics = haptics
    }

    private func configure() {
        if (self.haptic == nil) {
            do {
                self.haptic = UIImpactFeedbackGenerator(style: .light);
                self.haptic?.prepare();
                let session: AVAudioSession = AVAudioSession.sharedInstance()
                try session.setCategory(.playback, mode: .default, options: [.mixWithOthers]);
                try session.setActive(true);
                self.hapticUIKit = UINotificationFeedbackGenerator();
                self.hapticUIKit?.prepare();
            } catch {}
        }
    }
    
    private func triggerHaptic() {
        if (self.haptics) {
            self.configure();
            self.haptic?.impactOccurred();
        }
    }

    private func triggerErrorHaptic() {
        if (self.haptics) {
            self.configure();
            hapticUIKit?.notificationOccurred(.error);
        }
    }

    private func triggerSound(_ sound: SystemSoundID) {
        if (self.sounds) {
            self.configure();
            AudioServicesPlaySystemSound(sound);
        }
    }

    public func trigger(_ sound: SystemSoundID = Feedback.TAP, _ haptic: Int? = nil) {
        if (self.haptics) {
            self.configure();
            if let haptic = haptic {
                if (haptic == Feedback.HAPTIC_TAP) {
                    self.triggerHaptic();
                }
                else if (haptic == Feedback.HAPTIC_NOSET) {
                    self.triggerErrorHaptic();
                }
            }
        }
        if (self.sounds) {
            self.configure();
            AudioServicesPlaySystemSound(sound);
        }
    }
}
