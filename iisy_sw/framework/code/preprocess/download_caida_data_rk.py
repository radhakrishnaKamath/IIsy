import os
import argparse

parser = argparse.ArgumentParser()

# Add argument
parser.add_argument('-s', required=True, help='server number')
args = parser.parse_args()

# extract argument value
server_no = args.s

url1 = "https://data.caida.org/datasets/passive-2019/equinix-nyc/20190117-130000.UTC/"

file_n = "equinix-nyc."
dire = ["dirA", "dirB"]
ext = ".gz"

file_n1 = ["125910", "130000", "130100", "130200", "130300", "130400", "130500", "130600"]
file_n2 = ["130700", "130800", "130900", "131000", "131100", "131200", "131300", "131400"]
file_n3 = ["131500", "131600", "131700", "131800", "131900", "132000", "132100", "132200"]
file_n4 = ["132300", "132400", "132500", "132600", "132700", "132800", "132900", "133000"]
file_n5 = ["133100", "133200", "133300", "133400", "133500", "133600", "133700", "133800"]
file_n6 = ["133900", "134000", "134100", "134200", "134300", "134400", "134500", "134600"]
file_n7 = ["134700", "134800", "134900", "135000", "135100", "135200", "135300", "135400"]
file_n8 = ["135500", "135600", "135700", "135800", "135900", "140000", "140100"]

# file_no = ["125910",	"130000",	"131000",	"132000",	"133000",	"134000",	"135000",	"140000",
# 		   				"130100",	"131100",	"132100",	"133100",	"134100",	"135100",	"140100",
# 						"130200",	"131200",	"132200",	"133200",	"134200",	"135200",	
# 						"130300",	"131300",	"132300",	"133300",	"134300",	"135300",	
# 						"130400",	"131400",	"132400",	"133400",	"134400",	"135400",	
# 						"130500",	"131500",	"132500",	"133500",	"134500",	"135500",	
# 						"130600",	"131600",	"132600",	"133600",	"134600",	"135600",	
# 						"130700",	"131700",	"132700",	"133700",	"134700",	"135700",	
# 						"130800",	"131800",	"132800",	"133800",	"134800",	"135800",	
# 						"130900",	"131900",	"132900",	"133900",	"134900",	"135900"]

if server_no == 1:
	file_no = file_n1
elif server_no == 2:
	file_no = file_n2
elif server_no == 3:
	file_no = file_n3
elif server_no == 4:
	file_no = file_n4
elif server_no == 5:
	file_no = file_n5
elif server_no == 6:
	file_no = file_n6
elif server_no == 7:
	file_no = file_n7
else:
	file_no = file_n8

for i in dire:
	for j in file_no:
		file_name = file_n + i + ".20190117-" + j + ".UTC.anon.pcap"
		os.system("wget --server-response --http-user=cs18s030@smail.iitm.ac.in --http-password=26Krishn@ " + url1 + file_name + ext)
		os.system("gunzip " + file_name + ext)
		os.system("python2 form_iden_rk.py -i " + file_name + " -o ../../data/csv/caida_a_" + j + ".csv")
#		os.system("rm " + file_name)
