# steps
# read the test csv
# read the pcaps
# for each pcap check if the entries are in the test file
# if yes add it in a new pcap
# if no then go to next entry in pcap

from scapy.all import *
import numpy as np
import pandas as pd
import argparse
import os

parser = argparse.ArgumentParser()

# Add argument
parser.add_argument('-p', required=True, help='path to pcap')
parser.add_argument('-tc', required=True, help='path to test csv')
parser.add_argument('-o', required=True, help='path to test pcap')
args = parser.parse_args()

# extract argument value
input_pcap = args.p
input_test_csv = args.tc
outputfile = args.o

test_flows_df = pd.read_csv(input_test_csv)
test_flows = test_flows_df.to_numpy()

all_packets = rdpcap(input_pcap)
for packet in all_packets:
	try:
		proto = packet.proto
	except AttributeError:
		proto = 0
	proto = int(proto)
	try:
		eth_type = packet.type 
	except AttributeError:
		eth_type = 0
	eth_type = int(eth_type)
	if eth_type == 2048:
		try:
			src_ip = packet['IP'].src
		except AttributeError:
			src_ip = "0.0.0.0"
		try:
			dst_ip = packet['IP'].dst
		except AttributeError:
			dst_ip = "0.0.0.0"
		src_ip = str(src_ip)
		dst_ip = str(dst_ip)

	if proto==6 or proto==17:
		try:
			sport = packet.sport
		except AttributeError:
			sport = 0
		try:
			dport = packet.dport
		except AttributeError:
			dport = 0
		sport = int(sport)
		dport = int(dport)

	if eth_type == 2048:
		flow_tuple = [src_ip, dst_ip, sport, dport, proto]
		for test_flow in test_flows:
			if test_flow[6] == 6:
				check_tuple = [test_flow[0],test_flow[1],test_flow[2],test_flow[3],test_flow[6]]
			else:
				check_tuple = [test_flow[0],test_flow[1],test_flow[4],test_flow[5],test_flow[6]]
			
			if np.array_equal(flow_tuple,check_tuple):
				# store it in new pacp
				wrpcap(outputfile, packet, append=True)
			else:
				continue
