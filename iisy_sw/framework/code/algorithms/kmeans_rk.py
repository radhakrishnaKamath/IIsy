from sklearn.svm import SVC
from sklearn.svm import LinearSVC
from sklearn.naive_bayes import GaussianNB
import numpy as np
import pandas as pd
import argparse
from sklearn.metrics import accuracy_score
import pydotplus
from sklearn.cluster import KMeans
from sklearn.metrics import accuracy_score
from sklearn.metrics import classification_report
from sklearn.tree import export_graphviz
from sklearn.metrics import confusion_matrix
import matplotlib.pyplot as plt
from sklearn import linear_model
import os 

parser = argparse.ArgumentParser()

# Add argument
parser.add_argument('-i', required=True, help='path to dataset')
parser.add_argument('-o', required=True, help='path to outputfile')
args = parser.parse_args()

# extract argument
inputfile = args.i
outputfile = args.o

# Training set X
Set1 = pd.read_csv(inputfile)
Set = Set1.values.tolist()
X = [i[2:10] for i in Set]

class_names=['1','2','3','4']
feature_names=['tcp_src','tcp_dst','udp_src','udp_dst','proto','size','count','int_arr_time']

# prepare training and testing set
X = np.array(X)

# kmeans fit
kmeans = KMeans(n_clusters=4, random_state= 9).fit(X)
Predict_Y = kmeans.predict(X)

columns = ['src_ip','dst_ip','tcp_sport','tcp_dport','udp_sport','udp_dport','proto','size','count','int_arr_time','start_time','last_time','class']

# output the model in a text file, write it
for i in Set:
    x = [i[2:10]]
    x = np.array(x)
    y = kmeans.predict(x)
    dataframe = pd.DataFrame({'src_ip':[i[0]],'dst_ip':[i[1]],'tcp_sport':[i[2]],'tcp_dport':[i[3]],'udp_sport':[i[4]],'udp_dport':[i[5]],'proto':[i[6]],'size':[i[7]],'count':[i[8]],'int_arr_time':[i[9]],'start_time':[i[10]],'last_time':[i[11]],'class':y})
    if os.path.exists(outputfile):
        dataframe.to_csv(outputfile,index=False,sep=',',mode='a',columns = columns, header=False)
    else:
        dataframe.to_csv(outputfile,index=False,sep=',',columns = columns)