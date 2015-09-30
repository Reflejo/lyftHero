import socket
import sys

if len(sys.argv) < 2:
    print "Usage %s <port>" % sys.argv[0]
    sys.exit(0)

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect(("localhost", int(sys.argv[1])))
while True:
    id, colors, service, arrows, whammy, multi_switch = map(ord, s.recv(6))

    print "Instrument [id: %s], Buttons:" % id
    print "  colors:\t%s" % bin(colors)
    print "  service:\t%s" % bin(service)
    print "  arrows:\t%s" % bin(arrows)
    print "  whammy:\t%s" % bin(whammy)
    print "  multi_switch:\t%s" % bin(multi_switch)

s.close()
