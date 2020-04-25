#!/bin/bash

for i in $(seq $3 $4);
do
	cp ../../../../../wisc-data/"$1_pt$i" ../../data/pcap/
done

for i in $(seq $5 $6);
do
	cp ../../../../../wisc-data/"$2_pt$i" ../../data/pcap/
done

touch ../../data/csv/tmp0.csv
date
python2 flow_form_rk.py -i ../../data/pcap/univ1_pt1 -t ../../data/csv/tmp0.csv -o ../../data/csv/tmp1.csv
date
python2 flow_form_rk.py -i ../../data/pcap/univ1_pt2 -t ../../data/csv/tmp1.csv -o ../../data/csv/tmp2.csv
date
python2 flow_form_rk.py -i ../../data/pcap/univ1_pt3 -t ../../data/csv/tmp2.csv -o ../../data/csv/tmp3.csv
date
python2 flow_form_rk.py -i ../../data/pcap/univ1_pt4 -t ../../data/csv/tmp3.csv -o ../../data/csv/tmp4.csv
date
python2 flow_form_rk.py -i ../../data/pcap/univ1_pt5 -t ../../data/csv/tmp4.csv -o ../../data/csv/tmp5.csv
date
python2 flow_form_rk.py -i ../../data/pcap/univ1_pt6 -t ../../data/csv/tmp5.csv -o ../../data/csv/tmp6.csv
date
python2 flow_form_rk.py -i ../../data/pcap/univ1_pt7 -t ../../data/csv/tmp6.csv -o ../../data/csv/tmp7.csv
date
python2 flow_form_rk.py -i ../../data/pcap/univ1_pt8 -t ../../data/csv/tmp7.csv -o ../../data/csv/tmp8.csv
date
python2 flow_form_rk.py -i ../../data/pcap/univ1_pt9 -t ../../data/csv/tmp8.csv -o ../../data/csv/tmp9.csv
date
python2 flow_form_rk.py -i ../../data/pcap/univ1_pt10 -t ../../data/csv/tmp9.csv -o ../../data/csv/tmp10.csv
date
python2 flow_form_rk.py -i ../../data/pcap/univ1_pt11 -t ../../data/csv/tmp10.csv -o ../../data/csv/tmp11.csv
date
python2 flow_form_rk.py -i ../../data/pcap/univ1_pt12 -t ../../data/csv/tmp11.csv -o ../../data/csv/tmp12.csv
date
python2 flow_form_rk.py -i ../../data/pcap/univ1_pt13 -t ../../data/csv/tmp12.csv -o ../../data/csv/tmp13.csv
date
python2 flow_form_rk.py -i ../../data/pcap/univ1_pt14 -t ../../data/csv/tmp13.csv -o ../../data/csv/tmp14.csv
date
python2 flow_form_rk.py -i ../../data/pcap/univ1_pt15 -t ../../data/csv/tmp14.csv -o ../../data/csv/tmp15.csv
date
python2 flow_form_rk.py -i ../../data/pcap/univ1_pt16 -t ../../data/csv/tmp15.csv -o ../../data/csv/tmp16.csv
date
python2 flow_form_rk.py -i ../../data/pcap/univ1_pt17 -t ../../data/csv/tmp16.csv -o ../../data/csv/tmp17.csv
date
python2 flow_form_rk.py -i ../../data/pcap/univ1_pt18 -t ../../data/csv/tmp17.csv -o ../../data/csv/tmp18.csv
date
python2 flow_form_rk.py -i ../../data/pcap/univ1_pt19 -t ../../data/csv/tmp18.csv -o ../../data/csv/tmp19.csv
date
python2 flow_form_rk.py -i ../../data/pcap/univ1_pt20 -t ../../data/csv/tmp19.csv -o ../../data/csv/univ1_flow.csv
date
python2 flow_form_rk.py -i ../../data/pcap/univ2_pt0 -t ../../data/csv/tmp0.csv -o ../../data/csv/tmp20.csv
date
python2 flow_form_rk.py -i ../../data/pcap/univ2_pt1 -t ../../data/csv/tmp20.csv -o ../../data/csv/tmp21.csv
date
python2 flow_form_rk.py -i ../../data/pcap/univ2_pt2 -t ../../data/csv/tmp21.csv -o ../../data/csv/tmp22.csv
date
python2 flow_form_rk.py -i ../../data/pcap/univ2_pt3 -t ../../data/csv/tmp22.csv -o ../../data/csv/tmp23.csv
date
python2 flow_form_rk.py -i ../../data/pcap/univ2_pt4 -t ../../data/csv/tmp23.csv -o ../../data/csv/tmp24.csv
date
python2 flow_form_rk.py -i ../../data/pcap/univ2_pt5 -t ../../data/csv/tmp24.csv -o ../../data/csv/tmp25.csv
date
python2 flow_form_rk.py -i ../../data/pcap/univ2_pt6 -t ../../data/csv/tmp25.csv -o ../../data/csv/tmp26.csv
date
python2 flow_form_rk.py -i ../../data/pcap/univ2_pt7 -t ../../data/csv/tmp26.csv -o ../../data/csv/tmp27.csv
date
python2 flow_form_rk.py -i ../../data/pcap/univ2_pt8 -t ../../data/csv/tmp27.csv -o ../../data/csv/univ2_flow.csv
date


rm ../../data/csv/tmp*

# python2 flow_iden_rk.py -a1 $1 -a2 $3 -a3 $4 &
# python2 flow_iden_rk.py -a1 $2 -a2 $5 -a3 $6

# for i in $(seq $3 $4);
# do
# 	rm ../../data/pcap/"$1_$2$i"
# done