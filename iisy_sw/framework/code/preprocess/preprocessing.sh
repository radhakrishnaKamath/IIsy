#!/bin/bash

#./pcap_to_csv_rk.sh univ1 univ2 1 20 0 8

#python2 form_data_center_flows_rk.py -a1 univ1 -a2 1 -a3 20 -o ../../data/csv/univ1_flow.csv

#python2 form_data_center_flows_rk.py -a1 univ2 -a2 0 -a3 8 -o ../../data/csv/univ2_flow.csv

#python2 combine_csv_rk.py -a1 univ1 -a2 univ2 -a3 1 -a4 20 -a5 0 -a6 8 -o ../../data/csv/univ-flow.csv

#python2 classify_rk.py -i ../../data/csv/univ-flow.csv -o ../../data/csv/univ-classify-flow.csv

python2 split_data_rk.py -i ../../data/csv/univ-classify-flow.csv -otr ../../data/csv/univ-train.csv -ote ../../data/csv/univ-test.csv -otv ../../data/csv/univ-val.csv

# ./form_all_pcap_rk univ1 univ2 1 20 0 8

# cd ../algorithms/

# python2 dt_rk.py -i ../../data/csv/univ-train.csv -t ../../data/csv/univ-val.csv

# python2 log_reg_rk.py -i ../../data/csv/univ-train.csv -t ../../data/csv/univ-val.csv

# python2 svm_rk.py -i ../../data/csv/univ-train.csv -t ../../data/csv/univ-val.csv

#Obselete code

# ./pcap_to_csv_rk.sh univ2 pt 0 8
# python2 flow_iden_rk.py -i 16-09-27.pcap -o 16-09-27-flow.csv
# ./form_all_pcap_rk univ2 pt 0 8
