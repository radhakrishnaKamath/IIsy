#!/bin/bash

./pcap_to_csv_rk.sh univ1 pt 1 20

./pcap_to_csv_rk.sh univ2 pt 0 8

python2 combine_csv_rk.py -a1 univ1 -a2 univ2 -a3 1 -a4 1 -a5 0 -a6 0 -o ../../data/csv/univ-flow.csv

# python2 flow_iden_rk.py -i 16-09-27.pcap -o 16-09-27-flow.csv

python2 classify_rk.py -i ../../data/csv/univ-flow.csv -o ../../data/csv/univ-classify-flow.csv

python2 split_data_rk.py -i ../../data/csv/univ-classify-flow.csv -otr ../../data/csv/univ-train.csv -ote ../../data/csv/univ-test.csv -otv ../../data/csv/univ-val.csv

./form_all_pcap_rk univ1 pt 1 20

./form_all_pcap_rk univ2 pt 0 8

cd ../algorithms/

python2 dt_rk.py -i ../../data/csv/univ-train.csv -t ../../data/csv/univ-val.csv

python2 log_reg_rk.py -i ../../data/csv/univ-train.csv -t ../../data/csv/univ-val.csv

python2 svm_rk.py -i ../../data/csv/univ-train.csv -t ../../data/csv/univ-val.csv