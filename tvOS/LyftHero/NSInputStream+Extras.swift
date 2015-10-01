import Foundation

extension NSInputStream {

    /**
     Keep the stream alive by seting the option SO_KEEPALIVE to the underlying socket.
     
     - on: Whether the keep alive flag will be set to true or false.
     */
    func setKeepAlive(on: Bool) -> Bool {
        let socketData = self.propertyForKey(kCFStreamPropertySocketNativeHandle as String)
        var socket: CFSocketNativeHandle = 0
        socketData?.getBytes(&socket, length: sizeofValue(socket))

        var on: UInt32 = on ? 1 : 0
        return setsockopt(socket, SOL_SOCKET, SO_KEEPALIVE, &on, socklen_t(sizeofValue(on))) != -1
    }
}
