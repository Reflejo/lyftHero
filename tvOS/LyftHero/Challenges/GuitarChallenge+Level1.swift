
extension ChallengeViewController {

    func doLevel1(instrument: Instrument) throws {
        var session = self.sessionByDevice[instrument.deviceID] ?? Session(level: 1)
        let mask = instrument.colorsMask & 0b1111111

        if instrument.buttons.service & ButtonMask.Start != 0 {
            let letters = session.data.map { "\(UnicodeScalar($0))" }
            let nickname = letters.joinWithSeparator("")

            session = self.resetSession(forDeviceID: instrument.deviceID)

            let user = try self.scoreboard.addUser(named: nickname, scores: [1: 25])
            session.user = user

            Logger.log("Welcome \(user.name)!. Your score is: \(user.score)",
                instrument: instrument)
        }

        if instrument.buttons.pickOrArrows != .Idle {
            let seventhBit: UInt8 = instrument.buttons.pickOrArrows == .Up ? 1 : 0
            let finalMask = mask | (seventhBit << 6)

            if finalMask < 123 && finalMask > 64 {
                Logger.log("Entered letter: \(UnicodeScalar(finalMask))", instrument: instrument)
                session.data.append(Int(finalMask))
            }
        }

        self.sessionByDevice[instrument.deviceID] = session
    }
}
