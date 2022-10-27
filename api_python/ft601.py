from ftd3xx import ftd3xx, defines
import ctypes
import msvcrt

bytes_to_read = 32768
pipe_id = 0x82
timeout_in_ms = 10000

if __name__ == "__main__":
    data = ctypes.c_buffer(bytes_to_read)

    ft_status = ftd3xx.create(0, defines.FT_OPEN_BY_GUID)

    ft_status.setPipeTimeout(pipe_id, timeout_in_ms)

    msvcrt.getch()

    bytes_transferred = ft_status.readPipe(pipe_id, data, bytes_to_read)

    if ftd3xx.getStrError(ft_status.getLastError()) == "FT_TIMEOUT":
        print("Timeout has occured!")
        quit()
    elif ftd3xx.getStrError(ft_status.getLastError()) != "FT_OK":
        print("Failed due to other errors!")
        quit()
    else:
        hex_byte_data_list = [byte.encode('hex') for byte in data]
        print(hex_byte_data_list)
        print(bytes_transferred)

    ft_status.close()