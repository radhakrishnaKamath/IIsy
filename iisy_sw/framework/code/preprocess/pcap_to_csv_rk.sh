#!/bin/bash

for i in $(seq $3 $4);
do
	cp ../../../../../wisc-data/"$1_pt$i" ../../data/pcap/
done

for i in $(seq $5 $6);
do
	cp ../../../../../wisc-data/"$2_pt$i" ../../data/pcap/
done


#python2 flow_iden_rk.py -i ../../data/pcap/univ1_pt1 -o ../../data/csv/univ1_flow1.csv & 

#python2 flow_iden_rk.py -i ../../data/pcap/univ1_pt2 -o ../../data/csv/univ1_flow2.csv &

#python2 flow_iden_rk.py -i ../../data/pcap/univ1_pt3 -o ../../data/csv/univ1_flow3.csv &

#python2 flow_iden_rk.py -i ../../data/pcap/univ1_pt4 -o ../../data/csv/univ1_flow4.csv &

#python2 flow_iden_rk.py -i ../../data/pcap/univ1_pt5 -o ../../data/csv/univ1_flow5.csv &

#python2 flow_iden_rk.py -i ../../data/pcap/univ1_pt6 -o ../../data/csv/univ1_flow6.csv 

#python2 flow_iden_rk.py -i ../../data/pcap/univ1_pt7 -o ../../data/csv/univ1_flow7.csv &

#python2 flow_iden_rk.py -i ../../data/pcap/univ1_pt8 -o ../../data/csv/univ1_flow8.csv &

#python2 flow_iden_rk.py -i ../../data/pcap/univ1_pt9 -o ../../data/csv/univ1_flow9.csv &

#python2 flow_iden_rk.py -i ../../data/pcap/univ1_pt10 -o ../../data/csv/univ1_flow10.csv &

#python2 flow_iden_rk.py -i ../../data/pcap/univ1_pt11 -o ../../data/csv/univ1_flow11.csv &

#python2 flow_iden_rk.py -i ../../data/pcap/univ1_pt12 -o ../../data/csv/univ1_flow12.csv 

#python2 flow_iden_rk.py -i ../../data/pcap/univ1_pt13 -o ../../data/csv/univ1_flow13.csv &

#python2 flow_iden_rk.py -i ../../data/pcap/univ1_pt14 -o ../../data/csv/univ1_flow14.csv &

#python2 flow_iden_rk.py -i ../../data/pcap/univ1_pt15 -o ../../data/csv/univ1_flow15.csv &

#python2 flow_iden_rk.py -i ../../data/pcap/univ1_pt16 -o ../../data/csv/univ1_flow16.csv &

#python2 flow_iden_rk.py -i ../../data/pcap/univ1_pt17 -o ../../data/csv/univ1_flow17.csv &

#python2 flow_iden_rk.py -i ../../data/pcap/univ1_pt18 -o ../../data/csv/univ1_flow18.csv &

#python2 flow_iden_rk.py -i ../../data/pcap/univ1_pt19 -o ../../data/csv/univ1_flow19.csv &

#python2 flow_iden_rk.py -i ../../data/pcap/univ1_pt20 -o ../../data/csv/univ1_flow20.csv

python2 flow_iden_rk.py -i ../../data/pcap/univ2_pt0 -o ../../data/csv/univ2_flow0.csv

python2 flow_iden_rk.py -i ../../data/pcap/univ2_pt1 -o ../../data/csv/univ2_flow1.csv

python2 flow_iden_rk.py -i ../../data/pcap/univ2_pt2 -o ../../data/csv/univ2_flow2.csv

python2 flow_iden_rk.py -i ../../data/pcap/univ2_pt3 -o ../../data/csv/univ2_flow3.csv

python2 flow_iden_rk.py -i ../../data/pcap/univ2_pt4 -o ../../data/csv/univ2_flow4.csv

python2 flow_iden_rk.py -i ../../data/pcap/univ2_pt5 -o ../../data/csv/univ2_flow5.csv

python2 flow_iden_rk.py -i ../../data/pcap/univ2_pt6 -o ../../data/csv/univ2_flow6.csv

python2 flow_iden_rk.py -i ../../data/pcap/univ2_pt7 -o ../../data/csv/univ2_flow7.csv

python2 flow_iden_rk.py -i ../../data/pcap/univ2_pt8 -o ../../data/csv/univ2_flow8.csv



# python2 flow_iden_rk.py -a1 $1 -a2 $3 -a3 $4 &
# python2 flow_iden_rk.py -a1 $2 -a2 $5 -a3 $6

# for i in $(seq $3 $4);
# do
# 	rm ../../data/pcap/"$1_$2$i"
# done
