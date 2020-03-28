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
parser.add_argument('-c', required=True, help='classification')
args = parser.parse_args()

# extract argument value
inputfile = args.i
outputfile = args.o
classification =int(args.c)


#read the pcap file and extract the features for each packet
results = []
all_packets = rdpcap(inputfile)
for packet in all_packets:
    try:
        size = packet.len
    except AttributeError:
        size = 0
    try:
        proto = packet.proto
    except AttributeError:
        proto = 0
    try:
        src_ip = packet['IP'].src
        # print(src_ip)
    except AttributeError:
        src_ip = "0.0.0.0"
    try:
        dst_ip = packet['IP'].dst
    except AttributeError:
        dst_ip = "0.0.0.0"
    try:
        sport = packet.sport
    except AttributeError:
        sport = 0
    try:
        dport = packet.dport
    except AttributeError:
        dport = 0

    proto = int(proto)
    src_ip = str(src_ip)
    dst_ip = str(dst_ip)
    sport = int(sport)
    dport = int(dport)
    flag = 0
    if len(results)!=0:
        for i in range(0,len(results)):
            # print("0: " + src_ip + " " + results[i][0])
            if src_ip == results[i][0]:
                # print("1: " + dst_ip + " " + results[i][1])
                if dst_ip == results[i][1]:
                    # print("2: " + str(i[2]))
                    if sport == results[i][2]:
                        # print("3: " + str(i[3]))
                        if dport == results[i][3]:
                            # print("4: " + str(i[4]))
                            if proto == results[i][4]:
                                print("5_1: " + str(results[i][5]))
                                results[i][5] = results[i][5] + size
                                print("5_2: " + str(results[i][5]))
                                flag = 1
                                break
                            else:
                                # print("proto didn't match for i: " + str(i))
                                continue
                                # metric = [src_ip,dst_ip,sport,dport,proto,size]
                                # results.append(metric)
                        else:
                            # print("dport didn't match for i: " + str(i))
                            continue
                            # metric = [src_ip,dst_ip,sport,dport,proto,size]
                            # results.append(metric)
                    else:
                        # print("sport didn't match for i: " + str(i))
                        continue
                        # metric = [src_ip,dst_ip,sport,dport,proto,size]
                        # results.append(metric)
                else:
                    # print("dst_ip didn't match for i: " + str(i))
                    continue
                    # metric = [src_ip,dst_ip,sport,dport,proto,size]
                    # results.append(metric)
            else:
                # print("src_ip didn't match for i: " + str(i))
                continue
                # metric = [src_ip,dst_ip,sport,dport,proto,size]
                # results.append(metric)
        if flag == 0:
            metric = [src_ip,dst_ip,sport,dport,proto,size]
            results.append(metric)
    else:
        metric = [src_ip,dst_ip,sport,dport,proto,size]
        results.append(metric)

results = (np.array(results)).T

# store the features in the dataframe
dataframe = pd.DataFrame({'src_ip':results[0],'dst_ip':results[1],'sport':results[2],'dport':results[3],'proto':results[4],'size':results[5]})
columns = ['src_ip','dst_ip','sport','dport','proto','size']

# save the dataframe to the csv file, if not exsit, create one.
if os.path.exists(outputfile):
    dataframe.to_csv(outputfile,index=False,sep=',',mode='a',columns = columns, header=False)
else:
    dataframe.to_csv(outputfile,index=False,sep=',',columns = columns)


