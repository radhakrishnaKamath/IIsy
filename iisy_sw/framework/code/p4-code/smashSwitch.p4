/* -*- P4_16 -*- */
#include <core.p4>
#include <v1model.p4>

const bit<16> TYPE_IPV4 = 0x800;
const bit<8> TYPE_TCP = 0x06;
const bit<8> TYPE_UDP = 0x11;

/*************************************************************************
*********************** H E A D E R S  ***********************************
*************************************************************************/

typedef bit<9>  egressSpec_t;
typedef bit<48> macAddr_t;
typedef bit<32> ip4Addr_t;

header ethernet_t {
    macAddr_t dstAddr;
    macAddr_t srcAddr;
    bit<16>   etherType;
}

header ipv4_t {
    bit<4>    version;
    bit<4>    ihl;
    bit<8>    diffserv;
    bit<16>   totalLen;
    bit<16>   identification;
    bit<3>    flags;
    bit<13>   fragOffset;
    bit<8>    ttl;
    bit<8>    protocol;
    bit<16>   hdrChecksum;
    ip4Addr_t srcAddr;
    ip4Addr_t dstAddr;
}

header tcp_t {
    bit<16> srcPort;
    bit<16> dstPort;
    bit<32> seqNo;
    bit<32> ackNo;
    bit<4>  dataOffset;
    bit<4>  res;
    bit<1>  cwr;
    bit<1>  ece;
    bit<1>  urg;
    bit<1>  ack;
    bit<1>  psh;
    bit<1>  rst;
    bit<1>  syn;
    bit<1>  fin;
    bit<16> window;
    bit<16> checksum;
    bit<16> urgentPtr;
}

header udp_t {
    bit<16> srcPort;
    bit<16> dstPort;
    bit<16> len;
    bit<16> checksum;
}

struct tracking_metadata_t {
    bit<32> mKeyInTable;
    bit<32> mCountInTable;
	bit<32> mSizeInTable;
	bit<48> mIatInTable;
	bit<48> mLastTimeInTable;
    bit<32> mIndex;
    bit<32> mKeyCarried;
    bit<32> mCountCurrent;
	bit<32> mSizeCurrent;
	bit<48> mIatCurrent;
	bit<48> mLastTimeCurrent;
    bit<32> mSwapSpace;
}

header routing_metadata_t {
    bit<32> nhop_ipv4;
}

struct metadata {
    /* empty */
}

struct headers {
    ethernet_t          ethernet;
    ipv4_t              ipv4;
	tcp_t               tcp;
    udp_t               udp;
    routing_metadata_t  routing_metadata;
}

/*************************************************************************
*********************** P A R S E R  ***********************************
*************************************************************************/

parser MyParser(packet_in packet,
                out headers hdr,
                inout metadata meta,
                inout standard_metadata_t standard_metadata) {

    state start {
        transition parse_ethernet;
    }

    state parse_ethernet {
        packet.extract(hdr.ethernet);
        transition select(hdr.ethernet.etherType) {
            TYPE_IPV4: parse_ipv4;
            default: accept;
        }
    }

    state parse_ipv4 {
        packet.extract(hdr.ipv4);
        transition select(hdr.ipv4.protocol) {
            TYPE_TCP: parse_tcp;
            TYPE_UDP: parse_udp;
            default: accept;
        }
    }

	state parse_tcp {
        packet.extract(hdr.tcp);
        transition accept;
    }

    state parse_udp {
        packet.extract(hdr.udp);
        transition accept;
    }
}

/*************************************************************************
************   C H E C K S U M    V E R I F I C A T I O N   *************
*************************************************************************/

control MyVerifyChecksum(inout headers hdr, inout metadata meta) {   
    apply {  }
}


/*************************************************************************
**************  I N G R E S S   P R O C E S S I N G   *******************
*************************************************************************/

control MyIngress(inout headers hdr,
                  inout metadata meta,
                  inout standard_metadata_t standard_metadata) {
    
    tracking_metadata_t track_meta;
    
	register<bit<32>>(1024) flow_tracker;
    register<bit<32>>(1024) packet_counter;
	register<bit<32>>(1024) flow_size;
	register<bit<48>>(1024) flow_iat;
	register<bit<48>>(1024) flow_last_time;
register<bit<32>>(16)   drops_register;
    register<bit<1>>(16)    drops_register_enabled;
    
	bit<48> arrival_time;
	bit<48> time_threshold = (bit<48>)10;
	bit<32> size;
	bit<32> new_size;
	bit<32> size_threshold = (bit<32>)10240;
	bit<32> count;
	bit<1>  new_flow;
	bit<1>  size_overflow;

    action hash_and_store(ip4Addr_t ipAddr1, ip4Addr_t ipAddr2, bit<16> port11, bit<16> port12, bit<16> port21, bit<16> port22){
        // first table stage
        
		size = (hdr.ipv4.protocol == 0x06) ? (bit<32>)(hdr.ipv4.totalLen - (bit<16>)20 - (bit<16>)20) : (bit<32>)(hdr.ipv4.totalLen - (bit<16>)20 - (bit<16>)8);
		arrival_time = standard_metadata.ingress_global_timestamp;

        // hash using my custom function 
        // modify_field_with_hash_based_offset(track_meta.mIndex, 0, stage1_hash, 1024);

        hash(track_meta.mIndex, HashAlgorithm.crc16, (bit<32>)0, {ipAddr1, 
                                                                  ipAddr2,
                                                                  port11,
                                                                  port12,
                                                                  port21,
                                                                  port22,
                                                                  hdr.ipv4.protocol}, (bit<32>)32);

        track_meta.mKeyCarried = track_meta.mIndex;
		// read the key and value at that location
        flow_tracker.read(track_meta.mKeyInTable, track_meta.mIndex);
        packet_counter.read(track_meta.mCountInTable, track_meta.mIndex);
		flow_size.read(track_meta.mSizeInTable, track_meta.mIndex);
		flow_last_time.read(track_meta.mLastTimeInTable, track_meta.mIndex);
		flow_iat.read(track_meta.mIatInTable, track_meta.mIndex);

		// check if location is empty or has a differentkey in there
        // track_meta.mKeyInTable = (track_meta.mValid == 0)? track_meta.mKeyCarried : track_meta.mKeyInTable;
        track_meta.mSwapSpace = track_meta.mKeyInTable - track_meta.mKeyCarried;

		//check if the flow is same or new one
		new_flow = ((arrival_time - track_meta.mLastTimeInTable) < time_threshold) ? (bit<1>)0 : (bit<1>)1;

        // update hash table

		/*If the mSwapSpace == 0 then there is no collision, just update the values*/
        flow_tracker.write(track_meta.mIndex, ((track_meta.mSwapSpace == 0 && new_flow == 0) ? track_meta.mKeyInTable : track_meta.mKeyCarried));
        packet_counter.write(track_meta.mIndex, ((track_meta.mSwapSpace == 0 && new_flow == 0) ? (bit<32>)(track_meta.mCountInTable + 1) : (bit<32>)1));
		flow_size.write(track_meta.mIndex, ((track_meta.mSwapSpace == 0 && new_flow == 0) ? (bit<32>)(track_meta.mSizeInTable + size) : (bit<32>)size));
		flow_last_time.write(track_meta.mIndex, arrival_time);
		flow_iat.write(track_meta.mIndex, ((track_meta.mSwapSpace == 0 && new_flow == 0) ? (bit<48>)(arrival_time - track_meta.mLastTimeInTable) : (bit<48>)0));

		//check if the flow size is greater than the size_threshold
		flow_size.read(new_size, track_meta.mIndex);
		size_overflow = (new_size < size_threshold) ? (bit<1>)0 : (bit<1>)1; 

		/*If the mSwapSpace == 0 then there is no collision, just check the new flows the values*/
		track_meta.mCountCurrent 	= track_meta.mCountInTable;
		track_meta.mSizeCurrent 	= track_meta.mCountInTable;
		track_meta.mLastTimeCurrent = track_meta.mLastTimeInTable;
		track_meta.mIatCurrent 		= track_meta.mIatInTable;
    }

    action send_to_classify() {

    }

	action send_to_controller(){
		
	}

    action drop() {
        mark_to_drop(standard_metadata);
    }
    
    action ipv4_forward(macAddr_t dstAddr, egressSpec_t port) {
        standard_metadata.egress_spec = port;
        hdr.ethernet.srcAddr = hdr.ethernet.dstAddr;
        hdr.ethernet.dstAddr = dstAddr;
        hdr.ipv4.ttl = hdr.ipv4.ttl - 1;
    }

    table ipv4_lpm {
        key = {
            hdr.ipv4.dstAddr: lpm;
        }
        actions = {
            ipv4_forward;
            drop;
            NoAction;
        }
        size = 1024;
        default_action = drop();
    }
    
    apply {
        if (hdr.ipv4.isValid()) {
            ipv4_lpm.apply();
            if (hdr.tcp.isValid()) {
                hash_and_store(hdr.ipv4.srcAddr, hdr.ipv4.dstAddr, hdr.tcp.srcPort, hdr.tcp.dstPort, (bit<16>)0, (bit<16>)0);
            } else {
                hash_and_store(hdr.ipv4.srcAddr, hdr.ipv4.dstAddr, (bit<16>)0, (bit<16>)0, hdr.udp.srcPort, hdr.udp.dstPort);
            }
            if (new_flow == 0) {
                if (size_overflow == 0) {
                    //send_to_classify();
                }
            }
            if (track_meta.mSwapSpace == 1) {
                //send_to_classify();
            }
        }
    }
}

/*************************************************************************
****************  E G R E S S   P R O C E S S I N G   *******************
*************************************************************************/

control MyEgress(inout headers hdr,
                 inout metadata meta,
                 inout standard_metadata_t standard_metadata) {
    apply {  }
}

/*************************************************************************
*************   C H E C K S U M    C O M P U T A T I O N   **************
*************************************************************************/

control MyComputeChecksum(inout headers  hdr, inout metadata meta) {
    apply {
        update_checksum(
            hdr.ipv4.isValid(),
            { 
                hdr.ipv4.version,
                hdr.ipv4.ihl,
                hdr.ipv4.diffserv,
                hdr.ipv4.totalLen,
                hdr.ipv4.identification,
                hdr.ipv4.flags,
                hdr.ipv4.fragOffset,
                hdr.ipv4.ttl,
                hdr.ipv4.protocol,
                hdr.ipv4.srcAddr,
                hdr.ipv4.dstAddr 
            },
            hdr.ipv4.hdrChecksum,
            HashAlgorithm.csum16);
    }
}

/*************************************************************************
***********************  D E P A R S E R  *******************************
*************************************************************************/

control MyDeparser(packet_out packet, in headers hdr) {
    apply {
        packet.emit(hdr.ethernet);
        packet.emit(hdr.ipv4);
        packet.emit(hdr.tcp);
        packet.emit(hdr.udp);
    }
}

/*************************************************************************
***********************  S W I T C H  *******************************
*************************************************************************/

V1Switch(
MyParser(),
MyVerifyChecksum(),
MyIngress(),
MyEgress(),
MyComputeChecksum(),
MyDeparser()
) main;
