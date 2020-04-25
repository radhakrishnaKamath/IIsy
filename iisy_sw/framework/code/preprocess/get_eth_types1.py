from scapy.all import *

pkts = rdpcap('univ2_pt2')

for p in pkts:
    try:
        etype = p.type
    except AttributeError:
        etype = 0
    print(etype)

