import AVFoundation
import Foundation

/**
This enum represents the state of an arrow control.
 
- Up: The "up" button is pressed.
- Down: The "down" button is pressed.
- Left: The "down" button is pressed.
- Right: The "down" button is pressed.
- Idle: No button is currently pressed.
*/
enum ArrowState: UInt8 {
    case Idle = 8
    case Up = 0, Down = 4, Left = 6, Right = 2
}

struct Buttons {
    /// State of the colored buttons (both on guitars and drums)
    var colors: UInt8 = 0

    /// State of service buttons (Start, Select, etc)
    var service: UInt8 = 0

    /// State of arrow pads, can also be the guitar pick
    var pickOrArrows: ArrowState = .Idle

    /// State of the whammy bar (or drums pedal)
    var whammyBar: UInt8 = 0

    /// State of the guitars' multi-switch.
    var multiSwitch: UInt8 = 0
}

/**
This is the raw masks we get from the USB. Don't use this along with colorMask because they are different.
*/
struct ButtonMask {
    // Color buttons masks
    private static let Green: UInt8 = 0b10
    private static let Red: UInt8 = 0b100
    private static let Yellow: UInt8 = 0b1000
    private static let Blue: UInt8 = 0b1
    private static let Orange: UInt8 = 0b10000
    private static let Modifier: UInt8 = 0b1000000

    // Service buttons masks
    static let Select: UInt8 = 0b1
    static let Start: UInt8 = 0b10
}

// MARK: - Instrument

/**
Main instrument struct holds the state of the instrument (pressed buttons) and its device id.
*/
struct Instrument {
    static private let sounds = [
        ButtonMask.Green: Instrument.sound(named: "E"),
        ButtonMask.Red: Instrument.sound(named: "B"),
        ButtonMask.Yellow: Instrument.sound(named: "G"),
        ButtonMask.Blue: Instrument.sound(named: "D"),
        ButtonMask.Orange: Instrument.sound(named: "A")
    ]

    /// Unique device ID to identify the instrument device
    let deviceID: UInt

    /// The current state of all the buttons/controls.
    var buttons = Buttons()

    /// A mask composed with the bits of the guitar colors sorted following the actual buttons' ubication.
    var colorsMask: UInt8 {
        let getBit = { (color: UInt8) -> UInt8 in
            (self.buttons.colors & color) == 0 ? 0 : 1
        }

        return getBit(ButtonMask.Green)
            | getBit(ButtonMask.Red)      << 1
            | getBit(ButtonMask.Yellow)   << 2
            | getBit(ButtonMask.Blue)     << 3
            | getBit(ButtonMask.Orange)   << 4
            | getBit(ButtonMask.Modifier) << 5
    }

    init(deviceID: UInt) {
        self.deviceID = deviceID
    }

    /**
    This method should be called with a raw buffer (got from the USB dongle). It'll update the buttons
    state and play sounds as needed.
    */
    mutating func processInput(buffer: [UInt8]) {
        let arrows = ArrowState(rawValue: buffer[3]) ?? .Idle
        let buttons = Buttons(colors: buffer[1], service: buffer[2], pickOrArrows: arrows,
            whammyBar: buffer[4], multiSwitch: buffer[5])

        for bit in UInt8(0) ..< 5 {
            let mask = 1 << bit
            if mask & buttons.colors != mask & self.buttons.colors, let sound = Instrument.sounds[mask] {
                AudioServicesPlaySystemSound(sound)
            }
        }
        self.buttons = buttons
    }

    // MARK: Private Helpers

    static private func sound(named name: String) -> SystemSoundID {
        var mySound: SystemSoundID = 0
        if let URL = NSBundle.mainBundle().URLForResource(name, withExtension: "mp3") {
            AudioServicesCreateSystemSoundID(URL, &mySound)
        }
        return mySound
    }
}
