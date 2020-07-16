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
    bit<48> mFirstTimeInTable;
    bit<48> mLastTimeInTable;
    bit<32> mSizeInTable;
    bit<32> mIndex;
}

struct metadata {
    /* empty */
}

struct headers {
    ethernet_t          ethernet;
    ipv4_t              ipv4;
    tcp_t               tcp;
    udp_t               udp;
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

    bit<48> arrival_time = standard_metadata.ingress_global_timestamp;
    bit<32> size = hdr.ipv4.totalLen;

    register<bit<48>>(1024) packet_start_time_stage1;
    register<bit<48>>(1024) packet_last_time_stage1;
    register<bit<32>>(1024) packet_size_stage1;
    
    register<bit<48>>(1024) packet_start_time_stage2;
    register<bit<48>>(1024) packet_last_time_stage2;
    register<bit<32>>(1024) packet_size_stage2;
    
    register<bit<48>>(1024) packet_start_time_stage3;
    register<bit<48>>(1024) packet_last_time_stage3;
    register<bit<32>>(1024) packet_size_stage3;
    
    register<bit<48>>(1024) packet_start_time_stage4;
    register<bit<48>>(1024) packet_last_time_stage4;
    register<bit<32>>(1024) packet_size_stage4;
    
	bit<48> time_threshold = (bit<48>) 600;
    bit<48> duration_threshold = (bit<48>) 8;
    bit<48> first_time;
    bit<48> last_time;
	bit<32> new_size;
	bit<32> size_threshold = (bit<32>) 10485760;
    bit<1> new_flow;

    bit<32> key1;
    bit<32> key2;
    bit<32> key3;
    bit<32> key4;

    bit<32> size1;
    bit<32> size2;
    bit<32> size3;
    bit<32> size4;

    bit<48> time1;
    bit<48> time2;
    bit<48> time3;
    bit<48> time4;

    bit<1> val1;
    bit<1> val2;
    bit<1> val3;
    bit<1> val4;

    bit<1> f;
    bit<1> size_overflow;
    bit<1> duration_overflow;

    register<bit<1>>(4096) bloom_filter;

    action min_size(bit<32> size1, bit<32> size2, bit<32> size3, bit<32> size4) {

    	new_size = (size1 <= size2 && size3 <= size4) ? ((size1 <= size3) ? size1 : size3) : ((size2 <= size1 && size3 <= size4) ? ((size2 <= size3) ? size2 : size3) : ((size1 <= size2 && size4 <= size3) ? ((size1 <= size4) ? size1 : size4) : ((size2 <= size1 && size4 <= size3) ? ((size2 <= size4) ? size2 : size4) : size1)));
    }

    action max_time(bit<48> time1, bit<48> time2, bit<48> time3, bit<48> time4) {

    	first_time = (time1 <= time2 && time3 <= time4) ? ((time2 <= time4) ? time4 : time2) : ((time2 <= time1 && time3 <= time4) ? ((time1 <= time4) ? time4 : time1) : ((time1 <= time2 && time4 <= time3) ? ((time2 <= time3) ? time3 : time2) : ((time2 <= time1 && time4 <= time3) ? ((time1 <= time3) ? time3 : time1) : time4)));

    }

    action hash1(ip4Addr_t ipAddr1, ip4Addr_t ipAddr2, bit<16> port1, bit<16> port2){
        
        size = (hdr.ipv4.protocol == 0x06) ? (bit<32>)(hdr.ipv4.totalLen - (bit<16>)hdr.ipv4.minSizeInBytes() - (bit<16>)hdr.tcp.minSizeInBytes()) : (bit<32>)(hdr.ipv4.totalLen - (bit<16>)hdr.ipv4.minSizeInBytes() - (bit<16>)hdr.udp.minSizeInBytes());
		arrival_time = standard_metadata.ingress_global_timestamp;

        // hashing the 5 tuple
        hash(track_meta.mIndex, HashAlgorithm.crc16, (bit<32>)0, {ipAddr1, 
                                                                  ipAddr2,
                                                                  port1,
                                                                  port2,
                                                                  hdr.ipv4.protocol}, (bit<32>)32);

        // read the key and value at that location
        packet_last_time_stage1.read(last_time, track_meta.mIndex);
        packet_size_stage1.read(track_meta.mSizeInTable, track_meta.mIndex);
        packet_start_time_stage1.read(track_meta.mFirstTimeInTable, track_meta.mIndex);
        new_flow = ((arrival_time - last_time) > time_threshold) ? (bit<1>)1 : (bit<1>)0;
        
        // update hash table
        packet_start_time_stage1.write(track_meta.mIndex, ((new_flow == 0) ? (bit<48>)track_meta.mFirstTimeInTable : (bit<48>)arrival_time));
        packet_size_stage1.write(track_meta.mIndex, ((new_flow == 0) ? (bit<32>)(track_meta.mSizeInTable + size) : (bit<32>)size));
		packet_last_time_stage1.write(track_meta.mIndex, arrival_time);
    }

    action hash2(ip4Addr_t ipAddr1, ip4Addr_t ipAddr2, bit<16> port1, bit<16> port2){
        
        size = (hdr.ipv4.protocol == 0x06) ? (bit<32>)(hdr.ipv4.totalLen - (bit<16>)hdr.ipv4.minSizeInBytes() - (bit<16>)hdr.tcp.minSizeInBytes()) : (bit<32>)(hdr.ipv4.totalLen - (bit<16>)hdr.ipv4.minSizeInBytes() - (bit<16>)hdr.udp.minSizeInBytes());
		arrival_time = standard_metadata.ingress_global_timestamp;

        // hashing the 5 tuple
        hash(track_meta.mIndex, HashAlgorithm.crc32, (bit<32>)0, {ipAddr1, 
                                                                  ipAddr2,
                                                                  port1,
                                                                  port2,
                                                                  hdr.ipv4.protocol}, (bit<32>)32);

        // read the key and value at that location
        packet_last_time_stage2.read(last_time, track_meta.mIndex);
        packet_size_stage2.read(track_meta.mSizeInTable, track_meta.mIndex);
        packet_start_time_stage2.read(track_meta.mFirstTimeInTable, track_meta.mIndex);
        new_flow = ((arrival_time - last_time) > time_threshold) ? (bit<1>)1 : (bit<1>)0;
        
        // update hash table
        packet_start_time_stage2.write(track_meta.mIndex, ((new_flow == 0) ? (bit<48>)track_meta.mFirstTimeInTable : (bit<48>)arrival_time));
        packet_size_stage2.write(track_meta.mIndex, ((new_flow == 0) ? (bit<32>)(track_meta.mSizeInTable + size) : (bit<32>)size));
		packet_last_time_stage2.write(track_meta.mIndex, arrival_time);
    }

    action hash3(ip4Addr_t ipAddr1, ip4Addr_t ipAddr2, bit<16> port1, bit<16> port2){
        
        size = (hdr.ipv4.protocol == 0x06) ? (bit<32>)(hdr.ipv4.totalLen - (bit<16>)20 - (bit<16>)20) : (bit<32>)(hdr.ipv4.totalLen - (bit<16>)20 - (bit<16>)8);
		arrival_time = standard_metadata.ingress_global_timestamp;

        // hashing the 5 tuple
        hash(track_meta.mIndex, HashAlgorithm.csum16, (bit<32>)0, {ipAddr1, 
                                                                  ipAddr2,
                                                                  port1,
                                                                  port2,
                                                                  hdr.ipv4.protocol}, (bit<32>)32);

        // read the key and value at that location
        packet_last_time_stage3.read(last_time, track_meta.mIndex);
        packet_size_stage3.read(track_meta.mSizeInTable, track_meta.mIndex);
        packet_start_time_stage3.read(track_meta.mFirstTimeInTable, track_meta.mIndex);
        new_flow = ((arrival_time - last_time) > time_threshold) ? (bit<1>)1 : (bit<1>)0;
        
        // update hash table
        packet_start_time_stage3.write(track_meta.mIndex, ((new_flow == 0) ? (bit<48>)track_meta.mFirstTimeInTable : (bit<48>)arrival_time));
        packet_size_stage3.write(track_meta.mIndex, ((new_flow == 0) ? (bit<32>)(track_meta.mSizeInTable + size) : (bit<32>)size));
		packet_last_time_stage3.write(track_meta.mIndex, arrival_time);
    }

    action hash4(ip4Addr_t ipAddr1, ip4Addr_t ipAddr2, bit<16> port1, bit<16> port2){
        
        size = (hdr.ipv4.protocol == 0x06) ? (bit<32>)(hdr.ipv4.totalLen - (bit<16>)20 - (bit<16>)20) : (bit<32>)(hdr.ipv4.totalLen - (bit<16>)20 - (bit<16>)8);
		arrival_time = standard_metadata.ingress_global_timestamp;

        // hashing the 5 tuple
        hash(track_meta.mIndex, HashAlgorithm.crc16, (bit<32>)0, {ipAddr1, 
                                                                     ipAddr2,
                                                                     port1,
                                                                     port2,
                                                                     hdr.ipv4.protocol}, (bit<32>)32);

        // read the key and value at that location
        packet_last_time_stage4.read(last_time, track_meta.mIndex);
        packet_size_stage4.read(track_meta.mSizeInTable, track_meta.mIndex);
        packet_start_time_stage4.read(track_meta.mFirstTimeInTable, track_meta.mIndex);
        new_flow = ((arrival_time - last_time) > time_threshold) ? (bit<1>)1 : (bit<1>)0;
        
        // update hash table
        packet_start_time_stage4.write(track_meta.mIndex, ((new_flow == 0) ? (bit<48>)track_meta.mFirstTimeInTable : (bit<48>)arrival_time));
        packet_size_stage4.write(track_meta.mIndex, ((new_flow == 0) ? (bit<32>)(track_meta.mSizeInTable + size) : (bit<32>)size));
		packet_last_time_stage4.write(track_meta.mIndex, arrival_time);
    }

    action check_flow(ip4Addr_t ipAddr1, ip4Addr_t ipAddr2, bit<16> port1, bit<16> port2){
        hash(key1, HashAlgorithm.crc16, (bit<32>)0, {ipAddr1, ipAddr2, port1, port2, hdr.ipv4.protocol}, (bit<32>)32);
        hash(key2, HashAlgorithm.crc32, (bit<32>)0, {ipAddr1, ipAddr2, port1, port2, hdr.ipv4.protocol}, (bit<32>)32);
        hash(key3, HashAlgorithm.csum16, (bit<32>)0, {ipAddr1, ipAddr2, port1, port2, hdr.ipv4.protocol}, (bit<32>)32);
        hash(key4, HashAlgorithm.crc16, (bit<32>)0, {ipAddr1, ipAddr2, port1, port2, hdr.ipv4.protocol}, (bit<32>)32);

        bloom_filter.read(val1, key1);
        bloom_filter.read(val2, key2);
        bloom_filter.read(val3, key3);
        bloom_filter.read(val4, key4);

        f = (val1 != 1 || val2 != 1 || val3 != 1 || val4 != 1) ? (bit<1>)0 : (bit<1>)1;        
    }

    action classify_flow() {
        packet_size_stage1.read(size1, key1);
        packet_size_stage2.read(size2, key2);
        packet_size_stage3.read(size3, key3);
        packet_size_stage4.read(size4, key4);

        new_size = min_size(size1,size2,size3,size4);

        packet_start_time_stage1.read(time1, key1);
        packet_start_time_stage2.read(time2, key2);
        packet_start_time_stage3.read(time3, key3);
        packet_start_time_stage4.read(time4, key4);

        first_time = max_time(time1, time2, time3, time4);
        size_overflow = (new_size > size_threshold) ? (bit<1>)1 : (bit<1>)0;
        duration_overflow = ((arrival_time - first_time) > duration_threshold) ? (bit<1>)1 : (bit<1>)0;

        bloom_filter.write(key1, ((size_overflow == 1 && duration_overflow == 1) ? (bit<1>)1 : (bit<1>)0));
        bloom_filter.write(key2, ((size_overflow == 1 && duration_overflow == 1) ? (bit<1>)1 : (bit<1>)0));
        bloom_filter.write(key3, ((size_overflow == 1 && duration_overflow == 1) ? (bit<1>)1 : (bit<1>)0));
        bloom_filter.write(key4, ((size_overflow == 1 && duration_overflow == 1) ? (bit<1>)1 : (bit<1>)0));
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
                hash1(hdr.ipv4.srcAddr, hdr.ipv4.dstAddr, hdr.tcp.srcAddr, hdr.tcp.dstAddr);
                hash2(hdr.ipv4.srcAddr, hdr.ipv4.dstAddr, hdr.tcp.srcAddr, hdr.tcp.dstAddr);
                hash3(hdr.ipv4.srcAddr, hdr.ipv4.dstAddr, hdr.tcp.srcAddr, hdr.tcp.dstAddr);
                hash4(hdr.ipv4.srcAddr, hdr.ipv4.dstAddr, hdr.tcp.srcAddr, hdr.tcp.dstAddr);
                check_flow(hdr.ipv4.srcAddr, hdr.ipv4.dstAddr, hdr.tcp.srcAddr, hdr.tcp.dstAddr);
                if (f == (bit<1>)1) {
                    classify_flow();
                }
            } else {
                hash1(hdr.ipv4.srcAddr, hdr.ipv4.dstAddr, hdr.udp.srcAddr, hdr.udp.dstAddr);
                hash2(hdr.ipv4.srcAddr, hdr.ipv4.dstAddr, hdr.udp.srcAddr, hdr.udp.dstAddr);
                hash3(hdr.ipv4.srcAddr, hdr.ipv4.dstAddr, hdr.udp.srcAddr, hdr.udp.dstAddr);
                hash4(hdr.ipv4.srcAddr, hdr.ipv4.dstAddr, hdr.udp.srcAddr, hdr.udp.dstAddr);
                check_flow(hdr.ipv4.srcAddr, hdr.ipv4.dstAddr, hdr.udp.srcAddr, hdr.udp.dstAddr);
                if (f == (bit<1>)1) {
                    classify_flow();
                }
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
