import Foundation

private let RaspberryPI = (host: "localhost", port: 4000)

/**
This class holds the persistent connection with the RaspberryPI and listens from input on the
USB dongles.
 */
class InputManager: NSObject {

    private var host: String
    private var port: Int
    private var inputStream: NSInputStream?
    private var instrumentsByDeviceID: [UInt: Instrument] = [:]

    /// Closure that will be called when a new activity is received from any instrument.
    var onInstrumentActivity: ((instrument: Instrument) -> Void)?

    /**
    Creates an instance of an InputManager. Note that this will also connect our RaspberryPI proxy.
    */
    init(host: String = RaspberryPI.host, port: Int = RaspberryPI.port) {
        self.host = host
        self.port = port

        super.init()
        self.connect()
    }

    private func connect() {
        self.inputStream?.close()
        NSStream.getStreamsToHostWithName(self.host, port: self.port, inputStream: &self.inputStream,
            outputStream: nil)

        self.inputStream?.delegate = self
        self.inputStream?.scheduleInRunLoop(.mainRunLoop(), forMode: NSDefaultRunLoopMode)
        self.inputStream?.open()
    }
}

// MARK: - NSStreamDelegate implementation

extension InputManager: NSStreamDelegate {

    func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
        guard let inputStream = aStream as? NSInputStream else {
            return
        }

        switch eventCode {
            case NSStreamEvent.OpenCompleted:
                self.instrumentsByDeviceID = [:]
                inputStream.setKeepAlive(true)
                Logger.log("Instruments connected")

            case NSStreamEvent.ErrorOccurred, NSStreamEvent.EndEncountered:
                Logger.log("Oh noes, error when communicating with instruments! Retrying ...")
                if aStream.streamStatus != .Open {
                    let time = dispatch_time(DISPATCH_TIME_NOW, Int64(5 * Double(NSEC_PER_SEC)))
                    dispatch_after(time, dispatch_get_main_queue(), self.connect)
                }

            case NSStreamEvent.HasBytesAvailable:
                var buffer = [UInt8](count: 6, repeatedValue: 0)
                let bytes = self.inputStream?.read(&buffer, maxLength: buffer.count)
                if bytes >= 6 {
                    let deviceID = UInt(buffer[0])
                    var instrument = self.instrumentsByDeviceID[deviceID] ?? Instrument(deviceID: deviceID)
                    instrument.processInput(buffer)

                    self.onInstrumentActivity?(instrument: instrument)
                }

            default:
                break
        }
    }
}
