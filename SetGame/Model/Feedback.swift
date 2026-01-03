import SwiftUI
import AudioToolbox
import CoreHaptics
import AVFoundation
import UIKit

public class Feedback: ObservableObject
{
    public var haptics: Bool = false;
    public var sounds: Bool = false;

    public static let TAP: SystemSoundID    = 1104;
    public static let CANCEL: SystemSoundID = 1112;
    public static let SWOOSH: SystemSoundID = 1001;
    public static let BADING: SystemSoundID = 1253;

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
    
    public func triggerHaptic() {
        if (self.haptics) {
            self.configure();
            self.haptic?.impactOccurred();
        }
    }

    public func triggerErrorHaptic() {
        if (self.haptics) {
            self.configure();
            hapticUIKit?.notificationOccurred(.error);
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
