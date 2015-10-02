import UIKit

private let charactersSpeed = 0.05

class LoggerView: UITextView {

    /// Associated deviceID for this log viewer.
    @IBInspectable var linkedDeviceID: UInt = 0

    private var charactersQueue: [Character] = []

    override func awakeFromNib() {
        super.awakeFromNib()
        self.layoutManager.allowsNonContiguousLayout = false
    }

    /**
    Appends the given text to textfield and scrolls to the very bottom.
    
    - text: The text to be appended.
    - scrollToBottom: Whether or not to scroll to bottom after appending the given string.
    */
    func appendTextAnimated(text: String, scrollToBottom: Bool = true) {
        let animating = self.charactersQueue.count > 0
        self.charactersQueue.appendContentsOf((text + "\n").uppercaseString.characters)

        if !animating {
            self.animateNextCharacter()
        }

        if scrollToBottom {
            let bottomRange = NSRange(location: self.text.characters.count - 1, length: 0)
            self.scrollRangeToVisible(bottomRange)
        }
    }

    private func animateNextCharacter() {
        guard let character = self.charactersQueue.first else {
            return
        }

        self.charactersQueue.removeFirst()
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(charactersSpeed * Double(NSEC_PER_SEC)))
        dispatch_after(time, dispatch_get_main_queue()) {
            let underscore = self.text.removeAtIndex(self.text.endIndex.predecessor())
            self.text.append(character)
            self.text.append(underscore)
            self.animateNextCharacter()
        }
    }
}
