import pandas as pd
import numpy as np
import argparse
import os

parser = argparse.ArgumentParser()

# Add argument
parser.add_argument('-i', required=True, help='first keyword')
parser.add_argument('-o', required=True, help='output path')
args = parser.parse_args()

# extract argument value
inputfile = args.i
outputfile = args.o

result = []

columns = ['port_addr']

time_threshold = 50

flows = pd.read_csv(inputfile)
flows_np = flows.to_numpy()

for flow in flows_np:
	if len(result) == 0:
		result.append(flow[2])
	else:
		existing_src = 0
		for res in result:
			if res == flow[2]:
				existing_src = 1
				break
			else:
				continue
		if existing_src == 0:
			result.append(flow[2])
	
	if len(result) == 0:
		result.append(flow[3])
	else:
		existing_src = 0
		for res in result:
			if res == flow[3]:
				existing_src = 1
				break
			else:
				continue
		if existing_src == 0:
			result.append(flow[3])
	
	if len(result) == 0:
		result.append(flow[4])
	else:
		existing_src = 0
		for res in result:
			if res == flow[4]:
				existing_src = 1
				break
			else:
				continue
		if existing_src == 0:
			result.append(flow[4])
	
	if len(result) == 0:
		result.append(flow[5])
	else:
		existing_src = 0
		for res in result:
			if res == flow[5]:
				existing_src = 1
				break
			else:
				continue
		if existing_src == 0:
			result.append(flow[5])
print(len(result))	

# store the features in the dataframe
for i in result:
	dataframe = pd.DataFrame({'port_addr':[i]})
	# save the dataframe to the csv file, if not exsit, create one.
	if os.path.exists(outputfile):
		dataframe.to_csv(outputfile,index=False,sep=',',mode='a',columns = columns, header=False)
	else:
		dataframe.to_csv(outputfile,index=False,sep=',',columns = columns)

