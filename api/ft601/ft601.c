#include <stdio.h>
#include <initguid.h>
#include "FTD3XX.h"

#define BUFFER_SIZE (1000000)

DEFINE_GUID(GUID_DEVINTERFACE_FOR_D3XX, 0xd1e8fe6a, 0xab75, 0x4d9e, 0x97, 0xd2, 0x6, 0xfa, 0x22, 0xc7, 0x73, 0x6c);

int main() {
    FT_STATUS ftStatus = FT_OK;
    FT_HANDLE ftHandle;
    GUID DeviceGUID[2] = { 0 };

    UCHAR acReadBuf[BUFFER_SIZE] = { 0xAA };
    ULONG ulBytesRead = 0;

    memcpy(&DeviceGUID[0], &GUID_DEVINTERFACE_FOR_D3XX, sizeof(GUID));
    ftStatus = FT_Create(&DeviceGUID[0], FT_OPEN_BY_GUID, &ftHandle);
    if (FT_FAILED(ftStatus)) {
        return FALSE;
    }

    ftStatus = FT_ReadPipe(ftHandle, 0x82, acReadBuf, sizeof(acReadBuf), &ulBytesRead, NULL);
    if (FT_FAILED(ftStatus)) {
        printf("\nFAILED");
        FT_Close(ftHandle);
        return FALSE;
    }

    for (int i = 0; i < ulBytesRead; i++) {
        if ((i + 1) % 4 == 0)
            printf("%02x_%02x_%02x_%02x\n", acReadBuf[i], acReadBuf[i - 1], acReadBuf[i - 2], acReadBuf[i - 3]);
        else
            continue;
    }

    FT_Close(ftHandle);
    return TRUE;
}