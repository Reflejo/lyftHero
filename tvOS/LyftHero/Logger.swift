import Foundation

private let kLogMaximumLines = 1024

struct Logger {

    /**
    Logs a message in all visible log viewers.

    - message: The message to be shown.
    */
    static func log(message: String) {
        let loggerViews = AppDelegate.challengeViewController?.loggerViews ?? []
        loggerViews.forEach { $0.appendText(message) }
        print(message)
    }

    /**
    Logs a message along with the current state into the given device associated log view.

    - message: The message to be shown.
    - instrument: An instrument value that contains the current state and deviceID
    */
    static func log(message: String, instrument: Instrument) {
        let mask = String(instrument.colorsMask, radix: 2)
        let session = AppDelegate.challengeViewController?.sessionByDevice[instrument.deviceID]
        let nickname = session?.user?.name ?? "new"

        let message = "[\(nickname)][lvl \(session?.level ?? 0)][colors 0b\(mask)] \(message)"
        self.logInLoggerView(message, deviceID: instrument.deviceID)
    }

    // MARK: Private Helpers

    private static func logInLoggerView(message: String, deviceID: UInt) {
        let loggerViews = AppDelegate.challengeViewController?.loggerViews ?? []
        guard let loggerIndex = loggerViews.indexOf({ $0.linkedDeviceID == deviceID }) else {
            return
        }

        let loggerView = loggerViews[loggerIndex]
        loggerView.appendText(message)
        print(message)
    }
}
