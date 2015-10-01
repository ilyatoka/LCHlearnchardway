#ifndef LCHPrintBytesOfValue_h
#define LCHPrintBytesOfValue_h

typedef enum {
    kLCHEndianUnknown = 0,
    kLCHLittleEndian,
    kLCHBigEndian,
} LCHEndianType;

typedef union {
    uint16_t data;
    
    struct {
        uint8_t isLittleEndian;
        uint8_t isBigEndian;
    };
} LCHEndianFlag;

extern
void LCHPrintBitsOfValue(void *value, size_t typeSize, LCHEndianType endianType);

#endif
