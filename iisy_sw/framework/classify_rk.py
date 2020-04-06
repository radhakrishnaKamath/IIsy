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

all_flows = pd.read_csv(inputfile)

for i in range(0,all_flows.shape[0]-1):
	if all_flows.at[i,"size"] > (10*1024):
		all_flows.at[i,"size"] = all_flows.at[i,"size"]/1024
		dataframe = pd.DataFrame({'tcp_sport':[all_flows.at[i,"tcp_sport"]],'tcp_dport':[all_flows.at[i,"tcp_dport"]],'udp_sport':[all_flows.at[i,"udp_sport"]],'udp_dport':[all_flows.at[i,"udp_dport"]],'proto':[all_flows.at[i,"proto"]],'size':[all_flows.at[i,"size"]],'count':[all_flows.at[i,"count"]],'class':1})
		columns = ['tcp_sport','tcp_dport','udp_sport','udp_dport','proto','size','count','class']
		if os.path.exists(outputfile):
			dataframe.to_csv(outputfile,index=False,sep=',',mode='a',columns = columns, header=False)
		else:
			dataframe.to_csv(outputfile,index=False,sep=',',columns = columns)	
	else:
		all_flows.at[i,"size"] = all_flows.at[i,"size"]/1024
		dataframe = pd.DataFrame({'tcp_sport':[all_flows.at[i,"tcp_sport"]],'tcp_dport':[all_flows.at[i,"tcp_dport"]],'udp_sport':[all_flows.at[i,"udp_sport"]],'udp_dport':[all_flows.at[i,"udp_dport"]],'proto':[all_flows.at[i,"proto"]],'size':[all_flows.at[i,"size"]],'count':[all_flows.at[i,"count"]],'class':0})
		columns = ['tcp_sport','tcp_dport','udp_sport','udp_dport','proto','size','count','class']
		if os.path.exists(outputfile):
			dataframe.to_csv(outputfile,index=False,sep=',',mode='a',columns = columns, header=False)
		else:
			dataframe.to_csv(outputfile,index=False,sep=',',columns = columns)