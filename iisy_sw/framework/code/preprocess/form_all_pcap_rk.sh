#!/bin/bash

# for i in $(seq $3 $4);
# do
# 	cp ../../../../../wisc-data/"$1_$2$i" ../../data/pcap/
# done

python2 form_test_pcap_rk.py -p ../../data/pcap/univ1_pt1 -tc ../../data/csv/univ-test.csv -o ../../data/pcap/univ1_test-pkts_1.pcap &
python2 form_test_pcap_rk.py -p ../../data/pcap/univ1_pt2 -tc ../../data/csv/univ-test.csv -o ../../data/pcap/univ1_test-pkts_2.pcap &
python2 form_test_pcap_rk.py -p ../../data/pcap/univ1_pt3 -tc ../../data/csv/univ-test.csv -o ../../data/pcap/univ1_test-pkts_3.pcap &
python2 form_test_pcap_rk.py -p ../../data/pcap/univ1_pt4 -tc ../../data/csv/univ-test.csv -o ../../data/pcap/univ1_test-pkts_4.pcap &
python2 form_test_pcap_rk.py -p ../../data/pcap/univ1_pt5 -tc ../../data/csv/univ-test.csv -o ../../data/pcap/univ1_test-pkts_5.pcap &
python2 form_test_pcap_rk.py -p ../../data/pcap/univ1_pt6 -tc ../../data/csv/univ-test.csv -o ../../data/pcap/univ1_test-pkts_6.pcap
#python2 form_test_pcap_rk.py -p ../../data/pcap/univ1_pt7 -tc ../../data/csv/univ-test.csv -o ../../data/pcap/univ1_test-pkts_7.pcap &
#python2 form_test_pcap_rk.py -p ../../data/pcap/univ1_pt8 -tc ../../data/csv/univ-test.csv -o ../../data/pcap/univ1_test-pkts_8.pcap &
#python2 form_test_pcap_rk.py -p ../../data/pcap/univ1_pt9 -tc ../../data/csv/univ-test.csv -o ../../data/pcap/univ1_test-pkts_9.pcap &
#python2 form_test_pcap_rk.py -p ../../data/pcap/univ1_pt10 -tc ../../data/csv/univ-test.csv -o ../../data/pcap/univ1_test-pkts_10.pcap &
#python2 form_test_pcap_rk.py -p ../../data/pcap/univ1_pt11 -tc ../../data/csv/univ-test.csv -o ../../data/pcap/univ1_test-pkts_11.pcap &
#python2 form_test_pcap_rk.py -p ../../data/pcap/univ1_pt12 -tc ../../data/csv/univ-test.csv -o ../../data/pcap/univ1_test-pkts_12.pcap &
#python2 form_test_pcap_rk.py -p ../../data/pcap/univ1_pt13 -tc ../../data/csv/univ-test.csv -o ../../data/pcap/univ1_test-pkts_13.pcap &
#python2 form_test_pcap_rk.py -p ../../data/pcap/univ1_pt14 -tc ../../data/csv/univ-test.csv -o ../../data/pcap/univ1_test-pkts_14.pcap &
#python2 form_test_pcap_rk.py -p ../../data/pcap/univ1_pt15 -tc ../../data/csv/univ-test.csv -o ../../data/pcap/univ1_test-pkts_15.pcap &
#python2 form_test_pcap_rk.py -p ../../data/pcap/univ1_pt16 -tc ../../data/csv/univ-test.csv -o ../../data/pcap/univ1_test-pkts_16.pcap &
#python2 form_test_pcap_rk.py -p ../../data/pcap/univ1_pt17 -tc ../../data/csv/univ-test.csv -o ../../data/pcap/univ1_test-pkts_17.pcap &
#python2 form_test_pcap_rk.py -p ../../data/pcap/univ1_pt18 -tc ../../data/csv/univ-test.csv -o ../../data/pcap/univ1_test-pkts_18.pcap &
#python2 form_test_pcap_rk.py -p ../../data/pcap/univ1_pt19 -tc ../../data/csv/univ-test.csv -o ../../data/pcap/univ1_test-pkts_19.pcap &
#python2 form_test_pcap_rk.py -p ../../data/pcap/univ1_pt20 -tc ../../data/csv/univ-test.csv -o ../../data/pcap/univ1_test-pkts_20.pcap &

#python2 form_test_pcap_rk.py -p ../../data/pcap/univ2_pt0 -tc ../../data/csv/univ-test.csv -o ../../data/pcap/univ2_test-pkts_0.pcap &
#python2 form_test_pcap_rk.py -p ../../data/pcap/univ2_pt1 -tc ../../data/csv/univ-test.csv -o ../../data/pcap/univ2_test-pkts_1.pcap &
#python2 form_test_pcap_rk.py -p ../../data/pcap/univ2_pt2 -tc ../../data/csv/univ-test.csv -o ../../data/pcap/univ2_test-pkts_2.pcap &
#python2 form_test_pcap_rk.py -p ../../data/pcap/univ2_pt3 -tc ../../data/csv/univ-test.csv -o ../../data/pcap/univ2_test-pkts_3.pcap &
#python2 form_test_pcap_rk.py -p ../../data/pcap/univ2_pt4 -tc ../../data/csv/univ-test.csv -o ../../data/pcap/univ2_test-pkts_4.pcap &
#python2 form_test_pcap_rk.py -p ../../data/pcap/univ2_pt5 -tc ../../data/csv/univ-test.csv -o ../../data/pcap/univ2_test-pkts_5.pcap &
#python2 form_test_pcap_rk.py -p ../../data/pcap/univ2_pt6 -tc ../../data/csv/univ-test.csv -o ../../data/pcap/univ2_test-pkts_6.pcap &
#python2 form_test_pcap_rk.py -p ../../data/pcap/univ2_pt7 -tc ../../data/csv/univ-test.csv -o ../../data/pcap/univ2_test-pkts_7.pcap &
#python2 form_test_pcap_rk.py -p ../../data/pcap/univ2_pt8 -tc ../../data/csv/univ-test.csv -o ../../data/pcap/univ2_test-pkts_8.pcap


#for i in $(seq $3 $4);
#do
#	rm ../../data/pcap/"$1_pt$i"
#done

#for i in $(seq $5 $6);
#do
#	rm ../../data/pcap/"$2_pt$i"
#done

