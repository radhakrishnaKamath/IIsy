/* -*- P4_16 -*- */
#include <core.p4>
#include <v1model.p4>

const bit<16> TYPE_IPV4 = 0x800;

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

struct tracking_metadata_t {
    bit<32> mKeyInTable;
    bit<32> mCountInTable;
    bit<32> mIndex;
    bit<1>  mValid;
    bit<32> mKeyCarried;
    bit<32> mCountCarried;
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
    register<bit<32>>(1024) flow_tracker_stage1;
    register<bit<32>>(1024) packet_counter_stage1;
    register<bit<1>>(1024) valid_bit_stage1;

    register<bit<32>>(1024) flow_tracker_stage2;
    register<bit<32>>(1024) packet_counter_stage2;
    register<bit<1>>(1024) valid_bit_stage2;

    register<bit<32>>(1024) flow_tracker_stage3;
    register<bit<32>>(1024) packet_counter_stage3;
    register<bit<1>>(1024) valid_bit_stage3;
    
    register<bit<32>>(1024) flow_tracker_stage4;
    register<bit<32>>(1024) packet_counter_stage4;
    register<bit<1>>(1024) valid_bit_stage4;

    action drop() {
        mark_to_drop(standard_metadata);
    }

    action do_stage1(){
        // first table stage
        track_meta.mKeyCarried = hdr.ipv4.srcAddr;
        track_meta.mCountCarried = 0;

        // hash using my custom function 
        // modify_field_with_hash_based_offset(track_meta.mIndex, 0, stage1_hash, 1024);

        hash(track_meta.mIndex, HashAlgorithm.crc16, (bit<32>)0, {hdr.ipv4.srcAddr}, (bit<32>)32);

        // read the key and value at that location
        flow_tracker_stage1.read(track_meta.mKeyInTable, track_meta.mIndex);
        packet_counter_stage1.read(track_meta.mCountInTable, track_meta.mIndex);
        valid_bit_stage1.read(track_meta.mValid, track_meta.mIndex);

        // check if location is empty or has a differentkey in there
        track_meta.mKeyInTable = (track_meta.mValid == 0)? track_meta.mKeyCarried : track_meta.mKeyInTable;
        track_meta.mSwapSpace = track_meta.mKeyInTable - track_meta.mKeyCarried;

        // update hash table
        flow_tracker_stage1.write(track_meta.mIndex, track_meta.mKeyCarried);
        packet_counter_stage1.write(track_meta.mIndex, ((track_meta.mSwapSpace == 0)? (bit<32>)(track_meta.mCountInTable + 1) : (bit<32>)1));
        valid_bit_stage1.write(track_meta.mIndex, (bit<1>)1);

        // update metadata carried to the next table stage
        track_meta.mKeyCarried = ((track_meta.mSwapSpace == 0) ? 0: track_meta.mKeyInTable);
        track_meta.mCountCarried = ((track_meta.mSwapSpace == 0) ? 0: track_meta.mCountInTable);
    }

    action do_stage2(){
        // hash using my custom function 
        hash(track_meta.mIndex, HashAlgorithm.crc16, (bit<32>)0, {hdr.ipv4.srcAddr}, (bit<32>)32);

        // read the key and value at that location
        flow_tracker_stage2.read(track_meta.mKeyInTable, track_meta.mIndex);
        packet_counter_stage2.read(track_meta.mCountInTable, track_meta.mIndex);
        valid_bit_stage2.read(track_meta.mValid, track_meta.mIndex);

        // check if location is empty or has a differentkey in there
        track_meta.mKeyInTable = (track_meta.mValid == 0)? track_meta.mKeyCarried : track_meta.mKeyInTable;
        track_meta.mSwapSpace = (track_meta.mValid == 0)? 0 : track_meta.mKeyInTable - track_meta.mKeyCarried;

        // update hash table
        flow_tracker_stage2.write(track_meta.mIndex, ((track_meta.mSwapSpace == 0)? track_meta.mKeyInTable : ((track_meta.mCountInTable < track_meta.mCountCarried) ? track_meta.mKeyCarried : track_meta.mKeyInTable)));

        packet_counter_stage2.write(track_meta.mIndex, ((track_meta.mSwapSpace == 0)? track_meta.mCountInTable + track_meta.mCountCarried : ((track_meta.mCountInTable < track_meta.mCountCarried) ? track_meta.mCountCarried : track_meta.mCountInTable)));

        valid_bit_stage2.write(track_meta.mIndex, ((track_meta.mValid == 0) ? ((track_meta.mKeyCarried == 0) ? (bit<1>)0 : 1) : (bit<1>)1));

        // update metadata carried to the next table stage
        track_meta.mKeyCarried = ((track_meta.mSwapSpace == 0) ? 0: track_meta.mKeyInTable);
        track_meta.mCountCarried = ((track_meta.mSwapSpace == 0) ? 0: track_meta.mCountInTable);
    }

    action do_stage3(){
        // hash using my custom function 
        hash(track_meta.mIndex, HashAlgorithm.crc16, (bit<32>)0, {hdr.ipv4.srcAddr}, (bit<32>)32);

        // read the key and value at that location
        flow_tracker_stage3.read(track_meta.mKeyInTable, track_meta.mIndex);
        packet_counter_stage3.read(track_meta.mCountInTable, track_meta.mIndex);
        valid_bit_stage3.read(track_meta.mValid, track_meta.mIndex);

        // check if location is empty or has a differentkey in there
        track_meta.mKeyInTable = (track_meta.mValid == 0)? track_meta.mKeyCarried : track_meta.mKeyInTable;
        track_meta.mSwapSpace = (track_meta.mValid == 0)? 0 : track_meta.mKeyInTable - track_meta.mKeyCarried;

        // update hash table
        flow_tracker_stage3.write(track_meta.mIndex, ((track_meta.mSwapSpace == 0)? track_meta.mKeyInTable : ((track_meta.mCountInTable < track_meta.mCountCarried) ? track_meta.mKeyCarried : track_meta.mKeyInTable)));

        packet_counter_stage3.write(track_meta.mIndex, ((track_meta.mSwapSpace == 0)? track_meta.mCountInTable + track_meta.mCountCarried : ((track_meta.mCountInTable < track_meta.mCountCarried) ? track_meta.mCountCarried : track_meta.mCountInTable)));

        valid_bit_stage3.write(track_meta.mIndex, ((track_meta.mValid == 0) ? ((track_meta.mKeyCarried == 0) ? (bit<1>)0 : 1) : (bit<1>)1));

        // update metadata carried to the next table stage
        track_meta.mKeyCarried = ((track_meta.mSwapSpace == 0) ? 0: track_meta.mKeyInTable);
        track_meta.mCountCarried = ((track_meta.mSwapSpace == 0) ? 0: track_meta.mCountInTable);
    }

    action do_stage4(){
        // hash using my custom function 
        hash(track_meta.mIndex, HashAlgorithm.crc16, (bit<32>)0, {hdr.ipv4.srcAddr}, (bit<32>)32);

        // read the key and value at that location
        flow_tracker_stage4.read(track_meta.mKeyInTable, track_meta.mIndex);
        packet_counter_stage4.read(track_meta.mCountInTable, track_meta.mIndex);
        valid_bit_stage4.read(track_meta.mValid, track_meta.mIndex);

        // check if location is empty or has a differentkey in there
        track_meta.mKeyInTable = (track_meta.mValid == 0)? track_meta.mKeyCarried : track_meta.mKeyInTable;
        track_meta.mSwapSpace = (track_meta.mValid == 0)? 0 : track_meta.mKeyInTable - track_meta.mKeyCarried;

        // update hash table
        flow_tracker_stage4.write(track_meta.mIndex, ((track_meta.mSwapSpace == 0)? track_meta.mKeyInTable : ((track_meta.mCountInTable < track_meta.mCountCarried) ? track_meta.mKeyCarried : track_meta.mKeyInTable)));

        packet_counter_stage4.write(track_meta.mIndex, ((track_meta.mSwapSpace == 0)? track_meta.mCountInTable + track_meta.mCountCarried : ((track_meta.mCountInTable < track_meta.mCountCarried) ? track_meta.mCountCarried : track_meta.mCountInTable)));

        valid_bit_stage4.write(track_meta.mIndex, ((track_meta.mValid == 0) ? ((track_meta.mKeyCarried == 0) ? (bit<1>)0 : 1) : (bit<1>)1));

        // update metadata carried to the next table stage
        track_meta.mKeyCarried = ((track_meta.mSwapSpace == 0) ? 0: track_meta.mKeyInTable);
        track_meta.mCountCarried = ((track_meta.mSwapSpace == 0) ? 0: track_meta.mCountInTable);
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
            do_stage1();
            if(track_meta.mKeyCarried != 0){
                do_stage2();
                if(track_meta.mKeyCarried != 0){
                    do_stage3();
                    if(track_meta.mKeyCarried != 0){
                        do_stage4();
                    }
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