#!/usr/bin/env python3
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

import json
import re
import argparse

# Add argument
parser = argparse.ArgumentParser()
parser.add_argument('-i1', required=True, help='path to text tree')
parser.add_argument('-i2', required=True, help='path to text action')
parser.add_argument('-o', required=True, help='output path')
args = parser.parse_args()
inputfile = args.i1
actionfile = args.i2
outputfile = args.o

# read the action.text, find the actions for different classes.
def find_action(textfile):
    action =[]
    f = open(textfile)
    for line in f:
        n = re.findall(r"class", line)
        if n:
            fea = re.findall(r"\d",line)
            action.append(int(fea[1]))
    f.close()
    return action

# read the tree model, search the threshold value
def find_feature(textfile):
    fea = []
    proto = []
    tcp_src = []
    tcp_dst = []
    udp_src = []
    udp_dst = []
    tcp_flags = []
    ether_type = []
    flags = []
    size = []
    f = open(textfile,'r')
    for line in f:
        line_ele = line.split(" ")
        line_val = line_ele[3].split("(")
        line_val1 = line_val[1].split(")")
        centers = line_val1[0].split(",")
        centers.pop(-1)
        proto.append(centers[0])
        tcp_src.append(centers[1])
        tcp_dst.append(centers[2])
        udp_src.append(centers[3])
        udp_dst.append(centers[4])
        tcp_flags.append(centers[5])
        ether_type.append(centers[6])
        flags.append(centers[7])
        size.append(centers[8])
    f.close
    proto = [int(i) for i in proto]
    tcp_src = [int(i) for i in tcp_src]
    tcp_dst = [int(i) for i in tcp_dst]
    udp_src = [int(i) for i in udp_src]
    udp_dst = [int(i) for i in udp_dst]
    tcp_flags = [int(i) for i in tcp_flags]
    ether_type = [int(i) for i in ether_type]
    flags = [int(i) for i in flags]
    size = [int(i) for i in size]
    return proto,tcp_src,tcp_dst,udp_src,udp_dst,tcp_flags,ether_type,flags,size

def find_cluster(textfile,proto,tcp_src,tcp_dst,udp_src,udp_dst,tcp_flags,ether_type,flags,size):
        
    # print(centers)

        
        

# read the leaf node description and find the corresponding ranges
def find_classification(textfile,proto,tcp_src,tcp_dst,udp_src,udp_dst,tcp_flags,ether_type,flags,size):
    fea = []
    sign =[]
    num =[]
    f = open(textfile,'r')
    for line in f:
        n = re.findall(r"when", line)
        if n:
            fea.append(re.findall(r"(proto|tcp_src|tcp_dst|udp_src|udp_dst|tcp_flags|ether_type|flags|size)",line))
            sign.append(re.findall(r"(<=|>)",line))
            num.append(re.findall(r"\d+\.?\d*", line))
    f.close()


    protocol =[]
    srouce = []
    dstination =[]
    classfication =[]


    for i in range(len(fea)):
        feature1 = [i for i in range(len(proto) + 1)]
        feature2 = [i for i in range(len(tcp_src) + 1)]
        feature3 = [i for i in range(len(tcp_dst) + 1)]
        feature4 = [i for i in range(len(udp_src) + 1)]
        feature5 = [i for i in range(len(udp_dst) + 1)]
        feature6 = [i for i in range(len(tcp_flags) + 1)]
        feature7 = [i for i in range(len(ether_type) + 1)]
        feature8 = [i for i in range(len(flags) + 1)]
        feature9 = [i for i in range(len(size) + 1)]
        for j,feature in enumerate(fea[i]):
            if feature == 'proto':
                sig = sign[i][j]
                thres = int(float(num[i][j]))
                id = proto.index(thres)
                if sig == '<=':
                    while id < len(proto):
                        if id + 1 in feature1:
                            feature1.remove(id+1)
                        id = id+1
                else:
                    while id >= 0:
                        if id  in feature1:
                            feature1.remove(id)
                        id = id-1
            elif feature == 'src':
                sig = sign[i][j]
                thres = int(float(num[i][j]))
                id = src.index(thres)
                if sig == '<=':
                    while id < len(src):
                        if id+1 in feature2:
                            feature2.remove(id+1)
                        id = id+1
                else:
                    while id >= 0:
                        if id  in feature2:
                            feature2.remove(id)
                        id = id-1
            else:
                sig = sign[i][j]
                thres = int(float(num[i][j]))
                id = dst.index(thres)
                if sig == '<=':
                    while id < len(dst):
                        if id + 1 in feature3:
                            feature3.remove(id+1)
                        id = id+1
                else:
                    while id >= 0:
                        if id  in feature3:
                            feature3.remove(id)
                        id = id-1
        protocol.append(feature1)
        srouce.append(feature2)
        dstination.append(feature3)
        a= len(num[i])
        classfication.append(num[i][a-1])
    return(protocol,srouce,dstination,classfication)

# write json file information 
def write_info(file):
    file.write("\"target\":\"bmv2\",\n")
    file.write("\"p4info\":\"build/example.p4info\",\n")
    file.write("\"bmv2_json\":\"build/example.json\",\n")
    file.write("\"table_entries\":[\n")

# get action parameters 
def get_actionpara(action):
    para = {}
    if action == 0 :
        para = {}
    elif action == 2:
        para = {'dstAddr': '00:00:00:02:02:22','port': 2}
    elif action == 3:
        para = {'dstAddr': '00:00:00:03:03:33','port': 3}
    elif action == 4:
        para = {'dstAddr': '00:00:00:04:04:44','port': 4}

    return para

# write default action
def write_ingress_default(file):
    file.write("{\n")
    file.write("    \"table\": \"MyIngress.ipv4_exact\",\n")
    file.write("    \"default\": true ,\n")
    file.write("    \"action_name\": \"MyIngress.drop\",\n")
    file.write("    \"action_params\": {}\n")
    file.write("}\n")


# write the entries for decision table
def write_ingress(file,a,b,c,action,port):

    para = get_actionpara(port)

    data = {'table': 'MyIngress.ipv4_exact',
            'match': {'meta.action_select1': a,
                      'meta.action_select2': b,
                      'meta.action_select3': c },
            'action_name': action,
            'action_params': para

            }

    jsondata =json.dumps(data,
                      indent=4,
                      separators=(', ', ': '), ensure_ascii=False)
    file.write(jsondata)
    file.write(",\n")

# write the entries for class1_exact1 table
def write_class1_exact1(file,a,ind):
    data = {'table':'MyIngress.class1_exact1',
            'match': { 'meta.distance1': a},
            'action_name':'MyIngress.set_distance1',
            'action_params':{'featurevalue1':ind}
            }

    jsondata =json.dumps(data,
                      indent=4, ensure_ascii=False)
    file.write(jsondata)
    file.write(",\n")

# write the entries for class1_exact2 table
def write_class1_exact2(file,a,ind):
    data = {'table':'MyIngress.class1_exact2',
            'match': { 'meta.distance2': a},
            'action_name':'MyIngress.set_distance2',
            'action_params':{'featurevalue2':ind}
            }

    jsondata =json.dumps(data,
                      indent=4, ensure_ascii=False)
    file.write(jsondata)
    file.write(",\n")

# write the entries for class1_exact3 table
def write_class1_exact3(file,a,ind):
    data = {'table':'MyIngress.class1_exact3',
            'match': { 'meta.distance3': a},
            'action_name':'MyIngress.set_distance3',
            'action_params':{'featurevalue3':ind}
            }

    jsondata =json.dumps(data,
                      indent=4, ensure_ascii=False)
    file.write(jsondata)
    file.write(",\n")

# write the entries for class1_exact4 table
def write_class1_exact4(file,a,ind):
    data = {'table':'MyIngress.class1_exact4',
            'match': { 'meta.distance4': a},
            'action_name':'MyIngress.set_distance4',
            'action_params':{'featurevalue4':ind}
            }

    jsondata =json.dumps(data,
                      indent=4, ensure_ascii=False)
    file.write(jsondata)
    file.write(",\n")

# write the entries for class1_exact5 table
def write_class1_exact5(file,a,ind):
    data = {'table':'MyIngress.class1_exact5',
            'match': { 'meta.distance5': a},
            'action_name':'MyIngress.set_distance5',
            'action_params':{'featurevalue5':ind}
            }

    jsondata =json.dumps(data,
                      indent=4, ensure_ascii=False)
    file.write(jsondata)
    file.write(",\n")

# write the entries for class1_exact6 table
def write_class1_exact6(file,a,ind):
    data = {'table':'MyIngress.class1_exact6',
            'match': { 'meta.distance6': a},
            'action_name':'MyIngress.set_distance6',
            'action_params':{'featurevalue6':ind}
            }

    jsondata =json.dumps(data,
                      indent=4, ensure_ascii=False)
    file.write(jsondata)
    file.write(",\n")

# write the entries for class1_exact7 table
def write_class1_exact7(file,a,ind):
    data = {'table':'MyIngress.class1_exact7',
            'match': { 'meta.distance7': a},
            'action_name':'MyIngress.set_distance7',
            'action_params':{'featurevalue7':ind}
            }

    jsondata =json.dumps(data,
                      indent=4, ensure_ascii=False)
    file.write(jsondata)
    file.write(",\n")

# write the entries for class1_exact8 table
def write_class1_exact8(file,a,ind):
    data = {'table':'MyIngress.class1_exact8',
            'match': { 'meta.distance8': a},
            'action_name':'MyIngress.set_distance8',
            'action_params':{'featurevalue8':ind}
            }

    jsondata =json.dumps(data,
                      indent=4, ensure_ascii=False)
    file.write(jsondata)
    file.write(",\n")

# write the entries for class1_exact9 table
def write_class1_exact9(file,a,ind):
    data = {'table':'MyIngress.class1_exact9',
            'match': { 'meta.distance9': a},
            'action_name':'MyIngress.set_distance9',
            'action_params':{'featurevalue9':ind}
            }

    jsondata =json.dumps(data,
                      indent=4, ensure_ascii=False)
    file.write(jsondata)
    file.write(",\n")

# write the entries for class2_exact1 table
def write_class2_exact1(file,a,ind):
    data = {'table':'MyIngress.class2_exact1',
            'match': { 'meta.distance1': a},
            'action_name':'MyIngress.set_distance1',
            'action_params':{'featurevalue1':ind}
            }

    jsondata =json.dumps(data,
                      indent=4, ensure_ascii=False)
    file.write(jsondata)
    file.write(",\n")

# write the entries for class2_exact2 table
def write_class2_exact2(file,a,ind):
    data = {'table':'MyIngress.class2_exact2',
            'match': { 'meta.distance2': a},
            'action_name':'MyIngress.set_distance2',
            'action_params':{'featurevalue2':ind}
            }

    jsondata =json.dumps(data,
                      indent=4, ensure_ascii=False)
    file.write(jsondata)
    file.write(",\n")

# write the entries for class2_exact3 table
def write_class2_exact3(file,a,ind):
    data = {'table':'MyIngress.class2_exact3',
            'match': { 'meta.distance3': a},
            'action_name':'MyIngress.set_distance3',
            'action_params':{'featurevalue3':ind}
            }

    jsondata =json.dumps(data,
                      indent=4, ensure_ascii=False)
    file.write(jsondata)
    file.write(",\n")

# write the entries for class2_exact4 table
def write_class2_exact4(file,a,ind):
    data = {'table':'MyIngress.class2_exact4',
            'match': { 'meta.distance4': a},
            'action_name':'MyIngress.set_distance4',
            'action_params':{'featurevalue4':ind}
            }

    jsondata =json.dumps(data,
                      indent=4, ensure_ascii=False)
    file.write(jsondata)
    file.write(",\n")

# write the entries for class2_exact5 table
def write_class2_exact5(file,a,ind):
    data = {'table':'MyIngress.class2_exact5',
            'match': { 'meta.distance5': a},
            'action_name':'MyIngress.set_distance5',
            'action_params':{'featurevalue5':ind}
            }

    jsondata =json.dumps(data,
                      indent=4, ensure_ascii=False)
    file.write(jsondata)
    file.write(",\n")

# write the entries for class2_exact6 table
def write_class2_exact6(file,a,ind):
    data = {'table':'MyIngress.class2_exact6',
            'match': { 'meta.distance6': a},
            'action_name':'MyIngress.set_distance6',
            'action_params':{'featurevalue6':ind}
            }

    jsondata =json.dumps(data,
                      indent=4, ensure_ascii=False)
    file.write(jsondata)
    file.write(",\n")

# write the entries for class2_exact7 table
def write_class2_exact7(file,a,ind):
    data = {'table':'MyIngress.class2_exact7',
            'match': { 'meta.distance7': a},
            'action_name':'MyIngress.set_distance7',
            'action_params':{'featurevalue7':ind}
            }

    jsondata =json.dumps(data,
                      indent=4, ensure_ascii=False)
    file.write(jsondata)
    file.write(",\n")

# write the entries for class2_exact8 table
def write_class2_exact8(file,a,ind):
    data = {'table':'MyIngress.class2_exact8',
            'match': { 'meta.distance8': a},
            'action_name':'MyIngress.set_distance8',
            'action_params':{'featurevalue8':ind}
            }

    jsondata =json.dumps(data,
                      indent=4, ensure_ascii=False)
    file.write(jsondata)
    file.write(",\n")

# write the entries for class2_exact9 table
def write_class2_exact9(file,a,ind):
    data = {'table':'MyIngress.class2_exact9',
            'match': { 'meta.distance9': a},
            'action_name':'MyIngress.set_distance9',
            'action_params':{'featurevalue9':ind}
            }

    jsondata =json.dumps(data,
                      indent=4, ensure_ascii=False)
    file.write(jsondata)
    file.write(",\n")


proto,tcp_src,tcp_dst,udp_src,udp_dst,tcp_flags,ether_type,flags,size = find_feature(inputfile)
protocol,srouce,dstination,classfication = find_classification(inputfile,proto,tcp_src,tcp_dst,udp_src,udp_dst,tcp_flags,ether_type,flags,size)
find_cluster(inputfile,proto,tcp_src,tcp_dst,udp_src,udp_dst,tcp_flags,ether_type,flags,size)
action = find_action(actionfile)


runtime = open(outputfile,"w+")
runtime.write("{ \n")
write_info(runtime)

# parameter for decision table
for i in range(len(classfication)):
    a = protocol[i]
    id = len(a) - 1
    del a[1:id]
    if(len(a) == 1):
        a.append(a[0])
    b = srouce[i]
    id = len(b) - 1
    del b[1:id]
    if (len(b) == 1):
        b.append(b[0])
    c = dstination[i]
    id = len(c) - 1
    del c[1:id]
    if (len(c) == 1):
        c.append(c[0])

    ind = int(classfication[i])
    ac = action[ind]
    a = [i+1 for i in a]
    b = [i+1 for i in b]
    c = [i+1 for i in c]
    if ac == 0:
        write_ingress(runtime, a, b, c, 'MyIngress.drop', 0)
    else:
        print(a,b,c,ac)
        write_ingress(runtime, a, b, c,'MyIngress.ipv4_forward',ac)

#parameter in feature 1 table
if len(proto)!= 0:
    proto.append(0)
    proto.append(32)
    proto.sort()
    for i in range(len(proto)-1):
        write_class1_exactx(runtime, proto[i:i + 2], i+1)
else:
    write_class1_exactx(runtime,,1)
#parameter in feature 2 table
if len(tcp_src) != 0:
    tcp_src.append(0)
    tcp_src.append(65535)
    tcp_src.sort()
    for i in range(len(tcp_src)-1):
        write_feature2(runtime, tcp_src[i:i + 2], i+1)
#parameter in feature 3 table
if len(tcp_dst) != 0:
    tcp_dst.append(0)
    tcp_dst.append(65535)
    tcp_dst.sort()
    for i in range(len(tcp_dst)-1):
        write_feature3(runtime, tcp_dst[i:i + 2], i+1)



write_ingress_default(runtime)

runtime.write("] \n  }")
runtime.close()