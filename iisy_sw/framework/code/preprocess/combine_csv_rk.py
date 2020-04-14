import pandas as pd
import numpy as np
import argparse
import os

parser = argparse.ArgumentParser()

# Add argument
parser.add_argument('-a1', required=True, help='first keyword')
parser.add_argument('-a2', required=True, help='second keyword')
parser.add_argument('-a3', required=True, help='start count of a1')
parser.add_argument('-a4', required=True, help='end count jof a1')
parser.add_argument('-a5', required=True, help='start count of a2')
parser.add_argument('-a6', required=True, help='end count of a2')
parser.add_argument('-o', required=True, help='output path')
args = parser.parse_args()

# extract argument value
first_keyword = args.a1
second_keyword = args.a2
start_a1 = int(args.a3)
end_a1 = int(args.a4)
start_a2 = int(args.a5)
end_a2 = int(args.a6)
outputfile = args.o

columns = ['src_ip','dst_ip','tcp_sport','tcp_dport','udp_sport','udp_dport','proto','size','count','class']

for i in [1,2]:
	if i == 1:
		work_range = range(start_a1,end_a1+1)
	else:
		work_range = range(start_a2,end_a2+1)
	for j in work_range:
		if i == 1:
			path = "../../data/csv/"+first_keyword+"_flow"+str(j)+".csv"
		else:
			path = "../../data/csv/"+second_keyword+"_flow"+str(j)+".csv"
		flows_df = pd.read_csv(path)
		flows = flows_df.to_numpy()
		for flow in flows:
			dataframe = pd.DataFrame({'src_ip':[flow[0]],'dst_ip':[flow[1]],'tcp_sport':[flow[2]],'tcp_dport':[flow[3]],'udp_sport':[flow[4]],'udp_dport':[flow[5]],'proto':[flow[6]],'size':[flow[7]],'count':[flow[8]],'class':[flow[9]]})
			# save the dataframe to the csv file, if not exsit, create one.
			if os.path.exists(outputfile):
				dataframe.to_csv(outputfile,index=False,sep=',',mode='a',columns = columns, header=False)
			else:
				dataframe.to_csv(outputfile,index=False,sep=',',columns = columns)
