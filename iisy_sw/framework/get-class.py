import numpy as np
import pandas as pd
import argparse
import os

parser = argparse.ArgumentParser()

# Add argument
parser.add_argument('-i', required=True, help='path to dataset')
args = parser.parse_args()

# extract argument value
inputfile = args.i

class_flows = pd.read_csv(inputfile)

count0 = 0
count1 = 0

for i in range(0,class_flows.shape[0]-1):
	if class_flows.at[i,"class"] == 0:
		count0 = count0 + 1
	else:
		count1 = count1 + 1

print("count 0: " + str(count0) + " count 1: " + str(count1))
