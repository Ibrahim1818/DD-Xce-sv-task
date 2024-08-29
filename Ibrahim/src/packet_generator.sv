module packet_generator #(
    parameter WIDTH_TYPE    = 2,
    parameter WIDTH_PAYLOAD = 8,
    parameter WIDTH_PACKET  = 13,
    parameter BURST_SIZE    = 1
) (
    // Testbench --> Packet Generator
    input  logic                    clk,
    input  logic                    rst,
    input  logic [WIDTH_TYPE-1:0]   dest_addr,
    input  logic [WIDTH_TYPE-1:0]   pack_type,
    input  logic [WIDTH_PAYLOAD-1]  payload,
    input  logic                    eop, 
 
    // NOC Router --> Packet Generator
    input  logic                    ready,
    
    // Packet Generator --> NOC Router
    output logic [WIDTH_PACKET-1:0] packet,
    output logic                    valid,
    output logic                    last // Signal to indicate the last of burst transfer
);

logic [WIDTH_PACKET-1:0] packet_holder;
logic burst_count, count, burst_done;

// Assign the number of the packets to be transferred in burst mode
assign count = BURST_SIZE;

// Store the packet to be transferred
assign packet_holder = {eop, payload, pack_type, dest_addr};

// Signal to indicate the burst transfer is done
assign burst_done = (burst_count == 1'b0) ? 1'b1: 1'b0;


// At each posedge of clk if there is no reset, it will transnfer a packet
always_ff @(posedge clk or negedge rst) begin
    if(!rst) begin
        packet      <= 0;
        burst_count <= count;
        valid       <= 0;
        last        <= 0;
    end else if(!burst_done) begin
        valid       <= 1;
        last        <= 0;
        if(count == 1'b1) begin
            last        <= 1;
        end
        if(ready) begin
            burst_count <= count - 1;
            packet      <= packet_holder;
        end
    end else begin
        valid       <= 0;
        last        <= 0;
    end
end
endmodule

