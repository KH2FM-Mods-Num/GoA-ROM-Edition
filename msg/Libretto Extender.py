import struct
import os

x = os.listdir('libretto/')

for file in x:
    data = open('libretto/'+file,'rb').read()
    length  = struct.unpack('I',data[28:32])[0] #Bar Length
    command = struct.unpack('I',data[36:40])[0] #Number of Commands
    for i in range(command):
        j = 44 + i*8
        k = struct.unpack('I',data[j:j+4])[0]
        data = data[:j] + struct.pack('I',k+8) + data[j+4:] #Change all Command Pointers
    newcomm = 40 + command*8 #End of Command List
    length  = struct.pack('I',length+20)
    command = struct.pack('I',command+1)
    newdata = data[:28] + length + data[32:36] + command + data[40:newcomm]
    newdata = newdata + bytearray(8) + data[newcomm:] + bytearray(12)
    out  = open(file,'wb')
    out.write(newdata)
    out.close()
