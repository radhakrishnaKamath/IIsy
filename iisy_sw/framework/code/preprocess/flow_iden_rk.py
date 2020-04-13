#!/usr/bin/env python
#################################################################################
#
# Copyright (c) 2019 Zhaoqi Xiong
# All rights reserved.
#
#
# @NETFPGA_LICENSE_HEADER_START@
#
# Licensed to NetFPGA C.I.C. (NetFPGA) under one or more contributor
# license agreements.  See the NOTICE file distributed with this work for
# additional information regarding copyright ownership.  NetFPGA licenses this
# file to you under the NetFPGA Hardware-Software License, Version 1.0 (the
# "License"); you may not use this file except in compliance with the
# License.  You may obtain a copy of the License at:
#
#   http://www.netfpga-cic.org
#
# Unless required by applicable law or agreed to in writing, Work distributed
# under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
# CONDITIONS OF ANY KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations under the License.
#
# @NETFPGA_LICENSE_HEADER_END@
#
################################################################################# 

from scapy.all import *
import numpy as np
import pandas as pd
import argparse
import os

parser = argparse.ArgumentParser()

# Add argument
parser.add_argument('-i', required=True, help='path to dataset')
parser.add_argument('-o', required=True, help='output path')
args = parser.parse_args()

# extract argument value
inputfile = args.i
outputfile = args.o

print(inputfile)
print(outputfile)

#read the pcap file and extract the features for each packet
results = []
# cnt = 0
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
        # if cnt < 150:
            if len(results)!=0:
                for i in range(0,len(results)):
                    # print("src ip: " + src_ip + " results[i][1]: " + results[i][1])
                    if src_ip == results[i][1]:
                        # print("dst ip: " + dst_ip + " results[i][2]: " + results[i][2])
                        if dst_ip == results[i][2]:
                            if proto==6:
                                if sport == results[i][3]:
                                    if dport == results[i][4]:
                                        if proto == results[i][7]:
                                            size = size - (ihl*4 + 20)
                                            results[i][8] = results[i][8] + size
                                            results[i][9] = results[i][9] + 1
                                            flag = 1
                                            # cnt = cnt + 1
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
                                            # cnt = cnt + 1
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
                    # print([eth_type,src_ip,dst_ip,sport,dport,proto,size,1])
                    if proto == 6:
                        metric = [eth_type,src_ip,dst_ip,sport,dport,0,0,proto,size,1]
                    elif proto == 17:
                        metric = [eth_type,src_ip,dst_ip,0,0,sport,dport,proto,size,1]
                    else:
                        continue
                    # print("first entry:")
                    # print(metric)
                    results.append(metric)
                    # cnt = cnt + 1
            else:
                if proto == 6:
                    metric = [eth_type,src_ip,dst_ip,sport,dport,0,0,proto,size,1]
                elif proto == 17:
                    metric = [eth_type,src_ip,dst_ip,0,0,sport,dport,proto,size,1]
                # print("list empty first entry:")
                # print(metric)
                results.append(metric)
                # cnt = cnt + 1

results = (np.array(results))

# store the features in the dataframe

columns = ['src_ip','dst_ip','tcp_sport','tcp_dport','udp_sport','udp_dport','proto','size','count','class']
for i in results:
    # print(str(i[0]))
    dataframe = pd.DataFrame({'src_ip':[i[1]],'dst_ip':[i[2]],'tcp_sport':[i[3]],'tcp_dport':[i[4]],'udp_sport':[i[5]],'udp_dport':[i[6]],'proto':[i[7]],'size':[i[8]],'count':[i[9]],'class':0})
    # save the dataframe to the csv file, if not exsit, create one.
    if os.path.exists(outputfile):
        dataframe.to_csv(outputfile,index=False,sep=',',mode='a',columns = columns, header=False)
    else:
        dataframe.to_csv(outputfile,index=False,sep=',',columns = columns)
