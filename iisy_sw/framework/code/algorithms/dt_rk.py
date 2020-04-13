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
X = [i[0:7] for i in Set]
Y = [i[7] for i in Set]

# Test set Xt and Yt
Set2 = pd.read_csv(input)
Sett = Set2.values.tolist()
Xt = [i[0:7] for i in Set]
Yt = [i[7] for i in Set]

class_names = ['elephant','mouse']
feature_names = ['tcp_sport','tcp_dport','udp_sport','udp_dport','proto','size','count']

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