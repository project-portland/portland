#!/usr/bin/env python
#Make Portland File System
#Copyright 2018 Benji Dial
#Under GNU GPL v3.0

from sys import argv
from datetime import datetime
from os import path
from math import ceil

image = open(argv[1], 'wb')
boot = open(argv[2], 'rb')

print('Writing bootsector...')
image.write(boot.read(504))
image.write(bytes([ord('P'), ord('F'), ord('S'), 32, 1, 0]))
boot.seek(510)
image.write(boot.read(2))
boot.close()

time = int((datetime.now() - datetime(1970, 1, 1)).total_seconds()).to_bytes(8, 'little', signed=False)
sector = 16

print('Writing index...')
for each in argv[3:]:
    image.write(sector.to_bytes(4, 'little'))
    if len(each) == 0:
        image.write(bytes([0, 0, 0, 0]))
    elif len(each) == 1:
        image.write(bytes([ord(each[0]), 0, 0, 0]))
    elif len(each) == 2:
        image.write(bytes([ord(each[0]), ord(each[1]), 0, 0]))
    elif len(each) == 3:
        image.write(bytes([ord(each[0]), ord(each[1]), ord(each[2]), 0]))
    else:
        image.write(bytes(each[0:3], 'ascii'))
    sector += ceil(path.getsize(each) / 512.0) + 1
image.write(bytes([0] * (7680 - 8 * (len(argv) - 3))))

for each in argv[3:]:
    print('Writing', each, 'header...')
    image.write(time)
    image.write(time)
    image.write(time)
    image.write(path.getsize(each).to_bytes(2, 'little'))
    image.write(bytes[ceil(path.getsize(each) / 512.0)])
    image.write(bytes(each, 'ascii'))
    image.write([0] * (485 - len(each)))
    print('Writing', each, 'contents...')
    f = open(each, 'rb')
    image.write(f.read())
    f.close()
    image.write(bytes([0] * (511 - (path.getsize(each) - 1) % 512)))

print('Image complete!')
image.close()
