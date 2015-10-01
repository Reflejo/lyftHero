PROG = server

ifeq ($(shell uname), Linux)
	LDHIDFLAG = -lhidapi-hidraw
else
	LDHIDFLAG = -lhidapi
endif

CC = gcc
LDFLAGS = -L/usr/local/lib/ $(LDHIDFLAG)
CFLAGS = -O2 -Wall -DLINUX -I/usr/local/include/hidapi/ -g -DDEBUG

OBJS = usblayer.o server.o

all: $(OBJS)
	$(CC) -o $(PROG) $(OBJS) $(LDFLAGS)

clean: 
	rm -rf $(OBJS) $(PROG)
