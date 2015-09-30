#include <arpa/inet.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>
#include "usblayer.h"

bool pipe_device_to_socket(struct instrument_usb *instrument, int socket);

/**
 * Binds a socket to 0.0.0.0 and a given port, and listens for 1 connection,
 * over that connection we'll send all the changes we find on the usb devices.
 */
void start_server(int port) {
    struct sockaddr_in bind_address;
    struct instrument_usb instruments[INSTRUMENTS_COUNT] = {
        {NULL, GUITAR_PRODUCT_ID, 1, {0}},
        {NULL, GUITAR_PRODUCT_ID, 2, {0}},
        {NULL, DUMS_PRODUCT_ID, 3, {0}},
    };

    int fd, conn_socket, i = 0;

    fd = socket(AF_INET, SOCK_STREAM, 0);
    memset(&bind_address, 0, sizeof(bind_address));

    // Bind to 0.0.0.0:SOCKET_PORT
    bind_address.sin_family = AF_INET;
    bind_address.sin_addr.s_addr = htonl(INADDR_ANY);
    bind_address.sin_port = htons(port);
    if (bind(fd, (struct sockaddr *)&bind_address, sizeof(bind_address)) < 0) {
        printf("Can't bind server (maybe %d is already being use?).\n", port);
        exit(0);
    }

    // Listens for connections with a maximum of 1 concurrent connections
    listen(fd, 1);

    // This call is blocking, the kernel will stop the executing until the
    // TCP handshake is complete.
    printf("Listening on 0.0.0.0:%d\n", port);
    while ((conn_socket = accept(fd, (struct sockaddr*)NULL, NULL))) {
        printf("New connection (fd: %d)\n", conn_socket);

        while (1) {
            i = (i + 1) % INSTRUMENTS_COUNT;
            if (!pipe_device_to_socket(&instruments[i], conn_socket)) {
                break;
            }

            usleep(1000);
        }
    }

	hid_exit();
}

/**
 * Poll given instrument for new information and sends the information 
 * through the socket.
 *
 * @param instrument the instrument to be poll / sent over the wire.
 * @param socket the open socket to send the new information (if any).
 * @return wheter the send was successful or not. Note that not having
 *         data to send is counted as success.
 */
bool pipe_device_to_socket(struct instrument_usb *instrument, int socket) {
    if (poll_instrument(instrument)) {
#ifdef DEBUG
        dump_instrument(*instrument);
#endif

        byte buffer[6] = {
            instrument->unique_id,
            instrument->buttons.colors, instrument->buttons.service,
            instrument->buttons.arrows, instrument->buttons.whammy, 
            instrument->buttons.multi_switch
        };
        return send(socket, buffer, 6, 0);
    }

    return 1;
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        printf("Usage %s <bind port>", argv[0]);
        return 1;
    }

    start_server(atoi(argv[1]));
    return 0;
}
