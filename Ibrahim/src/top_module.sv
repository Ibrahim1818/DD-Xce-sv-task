module top_module #(
    parameter WIDTH_TYPE    = 2,
    parameter WIDTH_PAYLOAD = 8,
    parameter WIDTH_PACKET  = 13,
    parameter BURST_SIZE    = 1
) (
    // TESTBENCH --> TOP LEVEL
    input  logic                    clk,
    input  logic                    rst, 
    input  logic [WIDTH_TYPE-1:0]   dest_addr,
    input  logic [WIDTH_TYPE-1:0]   pack_type,
    input  logic [WIDTH_PAYLOAD-1:0]payload,
    input  logic                    eop,
    
    // TOP_LEVEL --> TESTBENCH
    output logic [WIDTH_PACKET-1:0] destination_out
);

logic [WIDTH_PACKET-1:0] packet;
logic valid, last, ready;

packet_generator #(
    .WIDTH_TYPE(WIDTH_TYPE),
    .WIDTH_PAYLOAD(WIDTH_PAYLOAD),
    .WIDTH_PACKET(WIDTH_PACKET),
    .BURST_SIZE(BURST_SIZE)
) pack_gen(
    .clk(clk),
    .rst(rst),
    .dest_addr(dest_addr),
    .pack_type(pack_type),
    .payload(payload),
    .eop(eop),
    .ready(ready),

    .packet(packet),
    .valid(valid),
    .last(last)
);

noc_router #(
    .WIDTH_PACKET(WIDTH_PACKET)
) noc_route(
    .clk(clk),
    .rst(rst),
    .packet(packet),
    .valid(valid),
    .last(last),

    .ready(ready),
    .destination_out(destination_out)
);

endmodule
