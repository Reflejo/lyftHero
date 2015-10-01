import UIKit

class LoggerView: UITextView {

    /// Associated deviceID for this log viewer.
    @IBInspectable var linkedDeviceID: UInt = 0

    override func awakeFromNib() {
        super.awakeFromNib()
        self.layoutManager.allowsNonContiguousLayout = false
    }

    /**
    Appends the given text to textfield and scrolls to the very bottom.
    
    - text: The text to be appended.
    - scrollToBottom: Whether or not to scroll to bottom after appending the given string.
    */
    func appendText(text: String, scrollToBottom: Bool = true) {
        self.text.appendContentsOf("\(text)\n")

        if scrollToBottom {
            let bottomRange = NSRange(location: self.text.characters.count - 1, length: 0)
            self.scrollRangeToVisible(bottomRange)
        }
   }
}
