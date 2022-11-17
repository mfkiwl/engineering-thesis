#include <stdio.h>
#include <initguid.h>
#include "FTD3XX.h"

#define BUFFER_SIZE (4096)

DEFINE_GUID(GUID_DEVINTERFACE_FOR_D3XX, 0xd1e8fe6a, 0xab75, 0x4d9e, 0x97, 0xd2, 0x6, 0xfa, 0x22, 0xc7, 0x73, 0x6c);

/*=============================================================================================================================*/
/*
* FUNCTION: Loopback_test
* =============================================================================================================================
* RETURN VALUE:
* BOOL - TRUE if passed, FALSE if failed
* 
* PARAMETERS:
* void
* 
* -----------------------------------------------------------------------------------------------------------------------------
* ABSTRACT:
* -----------------------------------------------------------------------------------------------------------------------------
* Function is sending incremented data to device then reads data received from device
* and compares sent data with received
* the operation is repeated 10 times(in every cycle 4096 Bytes is sent)
*/
/*=============================================================================================================================*/
BOOL Loopback_test(void) {
    FT_STATUS ftStatus = FT_OK;
    FT_HANDLE ftHandle;
    GUID DeviceGUID[2] = { 0 };

    UCHAR ucWritePipeId = 0x02;
    UCHAR ucReadPipeId = 0x82;

    UINT32 uiPrevData = 0;
    UINT32 uiData = 0;

    // Open device by GUID
    memcpy(&DeviceGUID[0], &GUID_DEVINTERFACE_FOR_D3XX, sizeof(GUID));
    ftStatus = FT_Create(&DeviceGUID[0], FT_OPEN_BY_GUID, &ftHandle);

    // Write and read loopback transfer
    UINT16 uiNumIterations = 10;
    for (UINT16 uiLoopCtr = 0; uiLoopCtr < uiNumIterations; uiLoopCtr++) {
        //
        // Write to channel 1 ep 0x02
        //
        UINT32 acWriteBuf[BUFFER_SIZE / 4] = { 0xFF };
        ULONG ulBytesWritten = 0;
        ULONG ulBytesToWrite = sizeof(acWriteBuf);

        // Prepare data to sent
        for (ULONG i = 0; i < BUFFER_SIZE / 4; i = i++)
            acWriteBuf[i] = i + (uiLoopCtr * (BUFFER_SIZE / 4));

        // Initialize Overlapped for asynchronous transfer
        OVERLAPPED vOverlappedWrite = { 0 };
        ftStatus = FT_InitializeOverlapped(ftHandle, &vOverlappedWrite);

        // Write asynchronously
        ftStatus = FT_WritePipe(ftHandle, ucWritePipeId, acWriteBuf, ulBytesToWrite, &ulBytesWritten, &vOverlappedWrite);
        if (ftStatus == FT_IO_PENDING) {
            // Wait until all requested data is sent
            do {
                // will return FT_IO_INCOMPLETE if not yet finish
                ftStatus = FT_GetOverlappedResult(ftHandle, &vOverlappedWrite, &ulBytesWritten, FALSE);

                if (ftStatus == FT_IO_INCOMPLETE) {
                    continue;
                }
                else if (FT_FAILED(ftStatus)) {
                    ftStatus = FT_ReleaseOverlapped(ftHandle, &vOverlappedWrite);
                    FT_Close(ftHandle);
                    return FALSE;
                }
                else {
                    break;
                }
            } while (1);
        }

        // Release Overlapped
        ftStatus = FT_ReleaseOverlapped(ftHandle, &vOverlappedWrite);

        //
        // Read from channel 1 ep 0x82
        //
        UCHAR acReadBuf[BUFFER_SIZE] = { 0x00 };
        ULONG ulBytesRead = 0;
        ULONG ulBytesToRead = sizeof(acReadBuf);

        // Initialize Overlapped for asynchronous transfer
        OVERLAPPED vOverlappedRead = { 0 };
        ftStatus = FT_InitializeOverlapped(ftHandle, &vOverlappedRead);

        // Read asynchronously
        ftStatus = FT_ReadPipe(ftHandle, ucReadPipeId, acReadBuf, ulBytesToRead, &ulBytesRead, &vOverlappedRead);
        if (ftStatus == FT_IO_PENDING) {
            // Wait until all requested data is received
            do {
                // will return FT_IO_INCOMPLETE if not yet finish
                ftStatus = FT_GetOverlappedResult(ftHandle, &vOverlappedRead, &ulBytesRead, FALSE);

                if (ftStatus == FT_IO_INCOMPLETE) {
                    continue;
                }
                else if (FT_FAILED(ftStatus)) {
                    ftStatus = FT_ReleaseOverlapped(ftHandle, &vOverlappedRead);
                    FT_Close(ftHandle);
                    return FALSE;
                }
                else {
                    break;
                }
            } while (1);
        }

        // Release Overlapped
        ftStatus = FT_ReleaseOverlapped(ftHandle, &vOverlappedWrite);

        // Check if results are correct
        for (ULONG ulByteIndex = 3; ulByteIndex < ulBytesRead; ulByteIndex = ulByteIndex + 4) {
            uiPrevData = uiData;
            uiData = ((acReadBuf[ulByteIndex] << 24) | (acReadBuf[ulByteIndex - 1] << 16) | (acReadBuf[ulByteIndex - 2] << 8) | (acReadBuf[ulByteIndex - 3] << 0));
            if (((uiPrevData + 1) != uiData) && (uiData != 0)) {
                ftStatus = FT_ReleaseOverlapped(ftHandle, &vOverlappedRead);
                FT_Close(ftHandle);
                return FALSE;
            }
        }
    }

    // Close device
    FT_Close(ftHandle);
    return TRUE;
}

int main() {
    if (Loopback_test() == TRUE) printf("PASSED"); else printf("FAILED");
}