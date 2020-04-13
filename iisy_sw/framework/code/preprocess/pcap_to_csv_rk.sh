#!/bin/bash

for i in $(seq $3 $4);
do
	cp ../../../wisc-data/"$1_$2$i" .
	python2 flow_iden_rk.py -i "$1_$2$i" -o "$1_flow$i.csv"
	rm "$1_$2$i"
done