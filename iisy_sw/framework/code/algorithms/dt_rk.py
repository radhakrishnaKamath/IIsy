import numpy as np
import pandas as pd
import argparse
from sklearn.tree import DecisionTreeClassifier
from sklearn.metrics import accuracy_score
from sklearn.tree import export_graphviz
import pydotplus

parser = argparse.ArgumentParser()

# Add argument
parser.add_argument('-i', required=True, help='path to dataset')
# parser.add_argument('-o', required=True, help='path to outputfile')
parser.add_argument('-t', required=True, help='path to testfile')
args = parser.parse_args()

# extract argument
input = args.i
# outputfile = args.o
testfile = args.t

# Training set X and Y
Set1 = pd.read_csv(input)
Set = Set1.values.tolist()
X = [i[2:10] for i in Set]
Y = [i[12] for i in Set]

# Test set Xt and Yt
Set2 = pd.read_csv(input)
Sett = Set2.values.tolist()
Xt = [i[2:10] for i in Set]
Yt = [i[12] for i in Set]

class_names = ['elephant','mouse']
feature_names = ['tcp_sport','tcp_dport','udp_sport','udp_dport','proto','size','count','int_arr_time']

def get_lineage(tree, feature_names):
    left = tree.tree_.children_left
    right = tree.tree_.children_right
    threshold = tree.tree_.threshold
    features = [feature_names[i] for i in tree.tree_.feature]
    value = tree.tree_.value
    le = '<='
    g = '>'
    # get ids of child nodes
    idx = np.argwhere(left == -1)[:, 0]
    
    # traverse the tree and get the node information
    def recurse(left, right, child, lineage=None):
        if lineage is None:
            lineage = [child]
        if child in left:
            parent = np.where(left == child)[0].item()
            split = 'l'
        else:
            parent = np.where(right == child)[0].item()
            split = 'r'
        
        lineage.append((parent, split, threshold[parent], features[parent]))
        if parent == 0:
            lineage.reverse()
            return lineage
        else:
            return recurse(left, right, parent, lineage)

    for j, child in enumerate(idx):
        clause = ' when '
        for node in recurse(left, right, child):
                if len(str(node)) < 3:
                    continue
                i = node
                
                if i[1] == 'l':
                    sign = le
                else:
                    sign = g
                clause = clause + i[3] + sign + str(i[2]) + ' and '
    
    # wirte the node information into text file
        a = list(value[node][0])
        ind = a.index(max(a))
        clause = clause[:-4] + ' then ' + str(ind)

		# prepare training and testing set
X = np.array(X)
Y = np.array(Y)
Xt = np.array(Xt)
Yt = np.array(Yt)

# decision tree fit
dt = DecisionTreeClassifier(max_depth = 5)
dt.fit(X, Y)
Predict_Y = dt.predict(X)
print(accuracy_score(Y, Predict_Y))

Predict_Yt = dt.predict(Xt)

e2e = 0
e2m = 0
m2e = 0
m2m = 0

for i in range(Predict_Yt.shape[0]):
	if Yt[i] == Predict_Yt[i] and Yt[i] == 1:
		e2e = e2e + 1
	elif Yt[i] == Predict_Yt[i] and Yt[i] == 0:
		m2m = m2m + 1
	elif Yt[i] != Predict_Yt[i] and Yt[i] == 0 and Predict_Yt[i] == 1:
		m2e = m2e + 1
	elif Yt[i] != Predict_Yt[i] and Yt[i] == 1 and Predict_Yt[i] == 0:
		e2m = e2m + 1

print("e2e: " + str(e2e) + " m2m: " + str(m2m) + " m2e: " + str(m2e) + " e2m: " + str(e2m))

threshold = dt.tree_.threshold
features  = [feature_names[i] for i in dt.tree_.feature]

print(threshold)
print(features)

# output the tree in a text file, write it
size = []
count = []
int_arr_time = []
for i, fe in enumerate(features):
    if fe == 'size':
        size.append(threshold[i])
    elif fe == 'count':
        if threshold[i] != -2.0:
            count.append(threshold[i])
    else:
        int_arr_time.append(threshold[i])
size = [int(i) for i in size]
count = [int(i) for i in count]
int_arr_time = [int(i) for i in int_arr_time]
size.sort()
count.sort()
int_arr_time.sort()
print(size)
print(count)
print(int_arr_time)
# tree = open(outputfile,"w+")
# tree.write("proto = ")
# tree.write(str(proto))
# tree.write(";\n")
# tree.write("src = ")
# tree.write(str(src))
# tree.write(";\n")
# tree.write("dst = ")
# tree.write(str(dst))
# tree.write(";\n")
# get_lineage(dt,feature_names)
# tree.close()
