#include "hidapi.h"

#define INSTRUMENTS_COUNT   3
#define GUITAR_PRODUCT_ID   0x200
#define DUMS_PRODUCT_ID     0x210
#define SONY_VENDOR_ID      0x12ba
#define RESPONSE_SIZE       7

typedef unsigned char byte;

/// This is how the bytes are packed on the raw USB report.
struct instrument_buttons {
    byte colors;
    byte service;
    byte arrows;
    byte whammy;
    byte multi_switch;
};

/// This is the representation of a connected USB instrument dongle.
struct instrument_usb {
    hid_device *hid;
    int product_id;
    byte unique_id;
    struct instrument_buttons buttons;
};

int connect_instrument(int product_id, hid_device **device);
int poll_instrument(struct instrument_usb *device);
void dump_instrument(struct instrument_usb device);
