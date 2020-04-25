from scapy.all import *

pkts = rdpcap('univ1_pt11')

for p in pkts:
    try:
        etype = p.type
    except AttributeError:
        etype = 0
    print(etype)

