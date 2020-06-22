from mininet.net import Mininet
from mininet.node import Controller, RemoteController
from mininet.cli import CLI
from mininet.log import setLogLevel
from mininet.link import Link, Intf, TCLink
from mininet.topo import Topo
from mininet.util import dumpNodeConnections

from p4_mininet import P4Switch, P4Host
from time import sleep

import logging
import os
import argparse

parser = argparse.ArgumentParser(description='Mininet demo')
parser.add_argument('--behavioral-exe1', help='Path to behavioral executable to core and aggregation switch',
					type=str, action="store", required=True)
parser.add_argument('--behavioral-exe2', help='Path to behavioral executable to edge switch',
					type=str, action="store", required=True)
parser.add_argument('--thrift-port', help='Thrift server port for table updates',
					type=int, action="store", default=9090)
parser.add_argument('--num-ports', help='Number of ports to the switch',
					type=int, action="store", default=2)
parser.add_argument('--mode', choices=['l2', 'l3'], type=str, default='l3')
parser.add_argument('--json1', help='Path to JSON config file for core and aggregation switch',
					type=str, action="store", required=True)
parser.add_argument('--json2', help='Path to JSON config file for edge switch',
					type=str, action="store", required=True)
parser.add_argument('--pcap-dump', help='Dump packets on interfaces to pcap files',
					type=str, action="store", required=False, default=False)

args = parser.parse_args()

class FatTree(Topo):
	def __init__(self, switch_port, sw_path1, json_path1, sw_path2, json_path2, thrift_port, pcap_dump):
		self.core_number = (switch_port/2)**2
		self.pods = switch_port
		self.aggregation_number = (switch_port/2)*pods
		self.edge_number = (switch_port/2)*pods
		self.hosts_number = (switch_port**3)/4
		self.sw_path1 = sw_path1
		self.json_path1 = json_path1
		self.sw_path2 = sw_path2
		self.json_path2 = json_path2
		self.thrift_port = thrift_port
		self.pcap_dump = pcap_dump
		Topo.__init__(self)

	def CreateNodes(self):
		self.FormCoreSwitch(self.core_number, self.sw_path1, self.json_path1, self.thrift_port, self.pcap_dump)
		self.FormAggregationSwitch(self.aggregation_number, self.sw_path1, self.json_path1, self.thrift_port, self.pcap_dump)
		self.FormEdgeSwitch(self.edge_number, self.sw_path2, self.json_path2, self.thrift_port, self.pcap_dump)
		self.FormHosts(self.hosts_number)

	def FormSwitch(self, count, pref, name_list, switch_list, sw_path, json_path, thrift_port, pcap_dump):
		for i in xrange(1, count+1):
			prefix = pref + "000"
			if i > 9 and i < 100:
				prefix = pref + "00"
			elif i > 99 and i < 999:
				prefix = pref + "0"
			else:
				prefix = pref
			name_list.append(prefix + str(i))
			switch_list.append(self.addSwitch(prefix + str(i),
											  sw_path = sw_path, 
											  json_path = json_path, 
											  thrift_port = thrift_port, 
											  pcap_dump = pcap_dump))

	def FormCoreSwitch(self, core_count, sw_path, json_path, thrift_port, pcap_dump):
		self.FormSwitch(core_count, "cs", self.core_switch_names, self.core_switch, sw_path, json_path, thrift_port, pcap_dump)

	def FormAggregationSwitch(self, aggregation_count, sw_path, json_path, thrift_port, pcap_dump):
		self.FormSwitch(aggregation_count, "as", self.aggregation_switch_names, self.aggregation_switch, sw_path, json_path, thrift_port, pcap_dump)

	def FormEdgeSwitch(self, edge_count, sw_path, json_path, thrift_port, pcap_dump):
		self.FormSwitch(edge_count, "es", self.edge_switch_names, self.edge_switch, sw_path, json_path, thrift_port, pcap_dump)

	def FormHosts(self, host_count):
		pref = "h"
		addr1 = 0
		addr2 = 0
		addr3 = 1

		for i in xrange(1, host_count+1):
			prefix = pref + "000000"
			if i > 9 and i < 100:
				prefix = pref + "00000"
			elif i > 99 and i < 999:
				prefix = pref + "0000"
			elif i > 999 and i < 9999:
				prefix = pref + "000"
			elif i > 9999 and i < 99999:
				prefix = pref + "00"
			elif i > 99999 and i < 999999:
				prefix = pref + "0"
			else:
				prefix = pref
			self.host_names.append(prefix + str(i))
			self.hosts.append(self.addHost(prefix + str(i),
							ip = "10.%d.%d.%d" % (addr1,addr2,addr3),
							mac = "00:00:00:%2x:%2x:%2x" % (addr1,addr2,addr3)))
			ip4 = ip4 + 1
			if ip4 == 254:
				ip3 = ip3 + 1
				ip4 = 0
			if ip3 == 254:
				ip2 = ip2 + 1
				ip3 = 0
			
	def FormLinks(self):

		bw_e2h = 1
		bw_a2e = 10
		bw_c2a = 10

		# Core to Aggregation switch
		core_ind = 0
		for i in xrange(self.aggregation_number):
			for j in xrange(self.pods/2):
				self.addLink(self.core_switch[(core_ind + j)],
							self.aggregation_switch[i],
							bw = bw_c2a,
							max_queue_size = 1000)
			core_ind = core_ind + self.pods/2
			if i % self.pods/2 == 0:
				core_ind = 0
		# Aggregation to Edge switch
		aggregation_ind = 0
		for i in xrange(self.edge_number):
			for j in xrange(self.pods/2):
				self.addLink(self.aggregation_switch[(aggregation_ind + j)],
							self.edge_switch[i],
							bw = bw_a2e,
							max_queue_size = 1000)
			if i % self.pods/2 == 0:
				aggregation_ind = aggregation_ind + self.pods/2
		# Edge to Hosts
		host_ind = 0
		for i in xrange(self.edge_number):
			for j in xrange(self.pods/2):
				self.addLink(self.edge_switch[i],
							self.hosts[host_ind + j],
							bw = bw_e2h,
							max_queue_size = 1000)
			host_ind = host_ind + self.pods/2

def main():

	switch_port = args.num_ports
	mode = args.mode
	
	#Form Topology, nodes and links
	topo = FatTree(switch_port,
					args.behavioral_exe1,
					args.json1,
					args.behavioral_exe2,
					args.json2,
					args.thrift_port,
					args.pcap_dump)
	topo.CreateNodes()
	topo.FormLinks()

	#Start Mininet
	net = Mininet(topo = topo,
					host = P4Host,
					switch = P4Switch,
					controller = None)
	net.start()

	sleep(1)

	print "Ready !"

	CLI( net )
	net.stop()


if __name__ == '__main__':
	setLogLevel('info')
	main()