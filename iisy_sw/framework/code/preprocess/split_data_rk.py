import numpy as np
import pandas as pd
import argparse
import os

parser = argparse.ArgumentParser()

# Add argument
parser.add_argument('-i', required=True, help='path to dataset')
parser.add_argument('-otr', required=True, help='train output path')
parser.add_argument('-ote', required=True, help='test output path')
parser.add_argument('-otv', required=True, help='validation output path')
args = parser.parse_args()

# extract argument value
inputfile = args.i
train_outputfile = args.otr
test_outputfile = args.ote
val_outputfile = args.otv

class_flows = pd.read_csv(inputfile)

columns = ['src_ip','dst_ip','tcp_sport','tcp_dport','udp_sport','udp_dport','proto','size','count','class']

class_flows = class_flows.sample(frac = 1).reset_index(drop=True)

train_ratio = 0.6*class_flows.shape[0]
train_ratio = int(train_ratio)

test_val_ratio = class_flows.shape[0]-train_ratio
test_ratio = test_val_ratio/2
test_ratio = int(test_ratio)
val_ratio = test_val_ratio - test_ratio


class_flows_train = class_flows.iloc[:train_ratio, :]
class_flows_val = class_flows.iloc[train_ratio:val_ratio, :]
class_flows_test = class_flows.iloc[val_ratio:, :]

# class_flows_test.columns = columns

# print("train head:")
# print(class_flows_train.head())
# print("test head:")
# print(class_flows_test.head())

class_flows_train.to_csv(train_outputfile,index=False,sep=',',columns=columns)
class_flows_val.to_csv(val_outputfile,index=False,sep=',',columns=columns)
class_flows_test.to_csv(test_outputfile,index=False,sep=',',columns=columns)