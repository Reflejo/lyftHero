#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include "usblayer.h"

/**
 * Copy from a usb dump to an instrument's button state.
 *
 * @param dst the pointer to the destination struct.
 * @param src the pointer to a buffer comming from the USB dongle.
 */
void statecpy(struct instrument_buttons *dst, byte *buffer) {
    dst->colors = buffer[0];
    dst->service = buffer[1];
    dst->arrows = buffer[2];
    dst->whammy = buffer[5] == 0x7f ? dst->whammy : buffer[5];
    dst->multi_switch = buffer[6] == 0x7f ? dst->multi_switch : buffer[6];
}

/**
 * Compare a buttons struct against an USB dump.
 *
 * @param dst the buttons struct to compare
 * @param src the pointer of the buffer received from the USB dongle.
 * @return 1 if buffer == dst or 0 otherwise.
 */
bool statecmp(struct instrument_buttons dst, byte *buffer) {
    return (dst.colors == buffer[0]
        && dst.service == buffer[1]
        && dst.arrows == buffer[2]
        && (dst.whammy == buffer[5] || buffer[5] == 0x7f)
        && (dst.multi_switch == buffer[6] || buffer[6] == 0x7f));
}

/**
 * From a list of connected instruments, we poll (read) the report data once,
 * this information is force-casted to our instrument_buttons struct(s). When
 * an error is found polling information, we just try to reconnect the device.
 *
 * @param device the instrument to poll; note that this struct will get 
 *               modified with the latest state.
 * @return 0 if an error occurred or 1 if poll got a new state
 */
int poll_instrument(struct instrument_usb *device) {
    // Try to reconnect device when we lose connection.
    if ((device->hid == NULL) 
        && connect_instrument(device->product_id, &device->hid) < 0) 
    {
        return 0;
    }

    byte *buffer = malloc(RESPONSE_SIZE * sizeof(byte));
    int res = hid_read(device->hid, buffer, RESPONSE_SIZE);
    if (res < RESPONSE_SIZE) {
        free(buffer);

        // When the response is negative, it usually means that there
        // was an error connecting to the device, lets just disconnect.
        if (res < 0) {
            hid_close(device->hid);
            device->hid = NULL;
        }
        return 0;
    }

    int new_state_found = statecmp(device->buttons, buffer) == 0;
    if (new_state_found) {
        statecpy(&device->buttons, buffer);
    }

    free(buffer);
    return new_state_found;
}

/**
 * Connect device by searching USBs with a matching product_id
 *
 * @param product_id the product_id to locate and connect.
 * @param device this reference will contained the connected device or NULL.
 * @return -1 if an error occurred or 0 if device was connected.
 */
int connect_instrument(int product_id, hid_device **device) {
    printf("Trying to connect device id: 0x%.4x\n", product_id);
    *device = hid_open(SONY_VENDOR_ID, product_id, NULL);
    if (*device == NULL) {
        printf("Error reading device id 0x%.4x\n", product_id);
        return -1;
    }

    printf("Device id: 0x%.3x connected\n", product_id);
    hid_set_nonblocking(*device, 1);
    return 0;
}

/**
 * Fills a buffer with a binary representaiton of a given int.
 *
 * @param n the integer to be represented in binary form.
 * @param buffer a pointer where the string will be fill.
 * @return the given pointer fill with the string.
 */
char *bin(unsigned n, char *buffer) {
    unsigned i, j = 0;
    for (i = 1 << 31; i > 0; i = i >> 1) {
        buffer[j++] = (n & i) ? '1' : '0';
    }
    buffer[j] = '\0';
    return buffer;
}

/**
 * Dumps the content of the instrument including the button state.
 *
 * @param the instrument dongle to dump.
 */
void dump_instrument(struct instrument_usb device) {
    char buffer[33];
    struct instrument_buttons buttons = device.buttons;

    printf("Instrument [id: %d]. Buttons:\n", device.unique_id);
    printf("\tcolor:\t\t%s\n", bin(buttons.colors, buffer));
    printf("\tservice:\t%s\n", bin(buttons.service, buffer));
    printf("\tarrows:\t\t%s\n", bin(buttons.arrows, buffer));
    printf("\twhammy bar:\t%d\n", buttons.whammy);
    printf("\tmulti switch:\t%d\n", buttons.multi_switch);
}
