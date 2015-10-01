import UIKit

typealias LevelClosure = (instrument: Instrument) throws -> Void

class ChallengeViewController: UIViewController {

    @IBOutlet private(set) var loggerViews: [LoggerView]!

    private let inputManager = InputManager()

    /// The current scoreboard holding users / scores. This will be (re)loaded at start.
    var scoreboard = Scoreboard()

    /// This map contains all the running sessions.
    var sessionByDevice: [UInt: Session] = [:]

    lazy private var levels: [LevelClosure] = [
        self.doLevel1,
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        self.inputManager.onInstrumentActivity = { [weak self] instrument in
            self?.handleInstrumentActivity(instrument)
        }
    }

    /**
    Resets the state of the given instrument (wipe the session).

    - deviceID: The deviceID for the instrument trying to reset the session
    - onlyData: A flag that indicates if we should only clean the session data or everything (logs out user).

    - returns: the newly created session (empty).
    */
    func resetSession(forDeviceID deviceID: UInt, onlyData: Bool = true) -> Session {
        self.sessionByDevice[deviceID]?.data = []

        if !onlyData {
            self.sessionByDevice[deviceID] = Session()
        }

        return self.sessionByDevice[deviceID] ?? Session()
    }

    // MARK: Private Helpers

    private func handleInstrumentActivity(instrument: Instrument) {
        let level = 0
        do {
            try self.levels[level](instrument: instrument)

        } catch LevelError.InvalidInput(let errorMessage) {
            Logger.log(errorMessage, instrument: instrument)
        } catch {
            Logger.log("Unknown Error", instrument: instrument)
        }
    }
}

