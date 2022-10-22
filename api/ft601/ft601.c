#include <stdio.h>
#include <initguid.h>
#include "FTD3XX.h"

#define BUFFER_SIZE (8192)

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

    UINT32 failCtr = 0;
    int loopctr = 0;
    UINT32 uiDecValue = 0, uiDecValuePREV = 0;
    ULONG ulBytesReadBuffer = 0;
    while (loopctr <  500) {
        loopctr++;
        ulBytesReadBuffer = ulBytesRead;
        ftStatus = FT_ReadPipe(ftHandle, 0x82, acReadBuf, sizeof(acReadBuf), &ulBytesRead, NULL);
        if (FT_FAILED(ftStatus)) {
            ulBytesRead = ulBytesReadBuffer;
            break;
        }

        for (int i = 0; i < ulBytesRead; i++) {
            if ((i + 1) % 4 == 0) {
                uiDecValuePREV = uiDecValue;
                uiDecValue = ((acReadBuf[i] << 24) | (acReadBuf[i - 1] << 16) | (acReadBuf[i - 2] << 8) | (acReadBuf[i - 3] << 0));
                if ((uiDecValuePREV + 1) != uiDecValue) {
                    failCtr++;
                    printf("%d. <----------------\n", failCtr);         
                }
                printf("%d\n", uiDecValue);
            }
            else
                continue;
        }
    }

    printf("\n\nfails = %d\n", failCtr - 1);
    printf("%d Bytes received\n\n", loopctr * ulBytesRead);

    FT_Close(ftHandle);
    return TRUE;
}