#!/bin/bash

python2 flow_iden_rk.py -i 16-09-27.pcap -o 16-09-27-flow.csv

python2 classify_rk.py -i 16-09-27-flow.csv -o 16-09-27-classify-flow.csv

python2 split_data_rk.py -i 16-09-27-classify-flow.csv -otr 16-09-27-train.csv -ote 16-09-27-test.csv

python2 dt_rk.py -i 16-09-27-train.csv -t 16-09-27-test.csv