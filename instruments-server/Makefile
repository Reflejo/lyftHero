PROG = server

CC = gcc
LDFLAGS = -L/usr/local/lib/ -lhidapi
CFLAGS = -O2 -Wall -DLINUX -I/usr/local/include/hidapi/ -g

OBJS = usblayer.o server.o

all: $(OBJS)
	$(CC) -o $(PROG) $(OBJS) $(LDFLAGS)
