#!/bin/bash

for i in $(seq $3 $4);
do
	cp ../../../../../wisc-data/"$1_$2$i" ../../data/pcap/
	python2 form_test_pcap_rk.py -p ../../data/pcap/"$1_$2$i" -tc ../../data/csv/univ-test.csv -o ../../data/pcap/test-pkts.pcap
	rm ../../data/pcap/"$1_$2$i"
done