#include <stdio.h>
#include <initguid.h>
#include "FTD3XX.h"

#define BUFFER_SIZE (8192*4)

DEFINE_GUID(GUID_DEVINTERFACE_FOR_D3XX, 0xd1e8fe6a, 0xab75, 0x4d9e, 0x97, 0xd2, 0x6, 0xfa, 0x22, 0xc7, 0x73, 0x6c);

int main() {
    FT_STATUS ftStatus = FT_OK;
    FT_HANDLE ftHandle;
    GUID DeviceGUID[2] = { 0 };

    OVERLAPPED vOverlapped = { 0 };
    UCHAR acReadBuf[BUFFER_SIZE] = { 0xFF };
    ULONG ulBytesRead = 0;
    UCHAR ucPipeID = 0x82;
    ULONG ulTimeoutInMs = 10000;
    UINT32 uiData = 0;

    memcpy(&DeviceGUID[0], &GUID_DEVINTERFACE_FOR_D3XX, sizeof(GUID));
    ftStatus = FT_Create(&DeviceGUID[0], FT_OPEN_BY_GUID, &ftHandle);

    // Initialize resource for overlapped parameter
    ftStatus = FT_InitializeOverlapped(ftHandle, &vOverlapped);

    // Set pipe timeout
    ftStatus = FT_SetPipeTimeout(ftHandle, ucPipeID, ulTimeoutInMs);

    // Wait for anykey press
    getch();

    // Read data from pipe
    ftStatus = FT_ReadPipe(ftHandle, ucPipeID, acReadBuf, sizeof(acReadBuf), &ulBytesRead, &vOverlapped);
    if (ftStatus == FT_IO_PENDING)
        ftStatus = FT_GetOverlappedResult(ftHandle, &vOverlapped, &ulBytesRead, TRUE);
        
    // Release resource for overlapped parameter
    FT_ReleaseOverlapped(ftHandle, &vOverlapped);
    
    // Handle errors & data
    if (ftStatus == FT_TIMEOUT) {
        printf("Timeout has occured!");
        return FALSE;
    }
    else if (ftStatus != FT_OK) {
        printf("Failed due to other errors!");
        return FALSE;
    }
    else {
        for (ULONG ulByteIndex = 3; ulByteIndex < ulBytesRead; ulByteIndex = ulByteIndex + 4) {
            uiData = ((acReadBuf[ulByteIndex] << 24) | (acReadBuf[ulByteIndex - 1] << 16) | (acReadBuf[ulByteIndex - 2] << 8) | (acReadBuf[ulByteIndex - 3] << 0));
            printf("%d\n", uiData);
        }
    }

    FT_Close(ftHandle);
    return TRUE;
}