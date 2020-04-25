from scapy.all import *
import numpy as np
import pandas as pd
import argparse
import os

parser = argparse.ArgumentParser()

# Add argument
parser.add_argument('-i', required=True, help='input file')
parser.add_argument('-t', required=True, help='tmp file')
parser.add_argument('-o', required=True, help='output file')
args = parser.parse_args()

# extract argument value
inputfile = args.i
tmpfile = args.t
outputfile = args.o

#read the pcap file and extract the features for each packet
columns = ['src_ip','dst_ip','tcp_sport','tcp_dport','udp_sport','udp_dport','proto','size','count','class']

print("outputfile " + outputfile)
print("tmpfile " + tmpfile)
print("inputfile " + inputfile)

if os.path.getsize(tmpfile) != 0:
	flows = pd.read_csv(tmpfile)
	results = flows.values.tolist()
else:
	results = []		

all_packets = rdpcap(inputfile)
for packet in all_packets:
	try:
		ihl = packet.ihl
	except AttributeError:
		ihl = 5
	try:
		size = packet.len
	except AttributeError:
		size = 0
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
	if eth_type == 33024:
		try:
			eth_type = packet['Dot1Q'].type
		except AttributeError:
			eth_type = eth_type
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

	flag = 0

	if eth_type==2048:
			if len(results)!=0:
				for i in range(0,len(results)):
					if src_ip == results[i][1]:
						if dst_ip == results[i][2]:
							if proto==6:
								if sport == results[i][3]:
									if dport == results[i][4]:
										if proto == results[i][7]:
											size = size - (ihl*4 + 20)
											results[i][8] = results[i][8] + size
											results[i][9] = results[i][9] + 1
											flag = 1
											break
										else:
											continue
									else:
										continue
								else:
									continue
							elif proto==17:
								if sport == results[i][5]:
									if dport == results[i][6]:
										if proto == results[i][7]:
											size = size - (ihl*4 + 8)
											results[i][8] = results[i][8] + size
											results[i][9] = results[i][9] + 1
											flag = 1
											break
										else:
											continue
									else:
										continue
								else:
									continue
							else:
								continue
						else:
							continue
					else:
						continue
				if flag == 0:
					if proto == 6:
						metric = [eth_type,src_ip,dst_ip,sport,dport,0,0,proto,size,1]
					elif proto == 17:
						metric = [eth_type,src_ip,dst_ip,0,0,sport,dport,proto,size,1]
					else:
						continue
					results.append(metric)
			else:
				if proto == 6:
					metric = [eth_type,src_ip,dst_ip,sport,dport,0,0,proto,size,1]
				elif proto == 17:
					metric = [eth_type,src_ip,dst_ip,0,0,sport,dport,proto,size,1]
				else:
					continue
				results.append(metric)

# store the features in the dataframe

for i in results:
	dataframe = pd.DataFrame({'src_ip':[i[1]],'dst_ip':[i[2]],'tcp_sport':[i[3]],'tcp_dport':[i[4]],'udp_sport':[i[5]],'udp_dport':[i[6]],'proto':[i[7]],'size':[i[8]],'count':[i[9]],'class':0})
	# save the dataframe to the csv file, if not exsit, create one.
	if os.path.exists(outputfile):
		dataframe.to_csv(outputfile,index=False,sep=',',mode='a',columns = columns, header=False)
	else:
		dataframe.to_csv(outputfile,index=False,sep=',',columns = columns)