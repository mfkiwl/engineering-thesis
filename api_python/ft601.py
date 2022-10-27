from ftd3xx import *
from ftd3xx.defines import *
import time

packets_to_read = 50

def read_pipe_0x82(d3xx, packets):
    data_out = []
    bytes_read = 0
    
    # Read data from ft601 device
    while(bytes_read < (packets * 4096)):
        output = d3xx.readPipeEx(0x82, 4096)
        bytes_read += output['bytesTransferred']
        data_out += output['bytes'].encode('hex')

    # Format data
    data_out = [''.join(x) for x in zip(data_out[::2], data_out[1::2])]
    data_out = [''.join(x) for x in zip(data_out[3::4], data_out[2::4], data_out[1::4], data_out[::4])]
    data_out = [int(x, 16) for x in data_out]

    return data_out, bytes_read

if __name__ == "__main__":
    

    ft_device = create(0, FT_OPEN_BY_GUID)
    if ft_device is None:
        print("ERROR: Please check if another D3XX application is open!")
        quit()

    start_time = time.time()
    data, bytes_read = read_pipe_0x82(ft_device, packets_to_read)
    stop_time = time.time()
    
    print(data)
    print(bytes_read)
    print("-----%s seconds ----", (stop_time- start_time))

    ft_device.close()

    