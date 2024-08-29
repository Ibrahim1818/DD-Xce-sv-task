module noc_router #(
    parameter WIDTH_PACKET = 13
) (
    // Packet Generator --> NOC Router
    input  logic                    clk,
    input  logic                    rst,
    input  logic                    last, 
    input  logic [WIDTH_PACKET-1:0] packet,
    input  logic                    valid,

    // NOC Router --> Packet Generator
    output logic                    ready,

    output logic [WIDTH_PACKET-1:0] destination_out
);

// Define the states of NOC Router Controller
typedef enum logic [1:0]{
    IDLE    = 2'b00,
    DECODE  = 2'b01, 
    ROUTING = 2'b10
} state_t;

state_t state, next_state;

logic decode_en, full, empty, wr_en, rd_en;
logic [WIDTH_PACKET-1:0] rd_data, wr_data;
logic [1:0] dest, pack;
logic route_done, write_dest;
logic [WIDTH_PACKET-1:0] destination [0:1];

assign wr_data = packet;
// FIFO module to buffer the incoming packets
small_fifo #(.WIDTH_PACKET(WIDTH_PACKET)) fifo(
    .clk(clk),
    .rst(rst),
    .wr_en(wr_en),
    .rd_en(rd_en),
    .wr_data(wr_data),

    .rd_data(rd_data),
    .full(full),
    .empty(empty)
);

// Decode the packet header
assign dest = (decode_en) ? (packet[1:0]) : 0;
assign pack = (decode_en) ? (packet[3:2]) : 0;
assign payload = packet[11:4];

always_ff @(posedge clk or negedge rst) begin
    if(!rst) begin
        for(int i=0; i < 2; i++) begin
            destination[i] <= 8'h0;
        end
        route_done <= 0;
    end else if(write_dest) begin
        if(dest == 2'b00) begin
            destination[0]  <= payload;
        end else if(dest == 2'b01) begin
            destination[1] <= payload;
        end else if(dest == 2'b10) begin
            destination[2] <= payload;
        end
        route_done <= 1;
        destination_out <= payload;
    end 
end


// CONTROLLER
always_ff @(posedge clk or negedge rst) begin
    if(!rst) begin
        state <= IDLE;
    end else begin
        state <= next_state;
    end
end

// next state and output logic 
always_comb begin
    case(state)
        IDLE: begin
            wr_en      = 0;
            rd_en      = 0;
            write_dest = 0;
            ready      = 1;
            decode_en  = 0;

            if(!valid) begin
                next_state = IDLE;
            end else if(last)begin
                next_state = DECODE;
                rd_en      = 1;
                decode_en  = 1;
            end else begin
                next_state = IDLE;
                wr_en      = 1;
            end 
        end
        DECODE: begin
            wr_en      = 0;
            rd_en      = 0;
            write_dest = 0;
            ready      = 0;
            decode_en  = 0;

            if((dest == 2'b00 )|| (dest == 2'b01) || (dest == 2'b10) || (dest == 2'b11)) begin
                next_state = ROUTING;
                write_dest = 1;
            end
        end
        ROUTING: begin
            wr_en      = 0;
            rd_en      = 0;
            write_dest = 1;
            ready      = 0;
            decode_en  = 0;

            if(!route_done) begin
                next_state = ROUTING;
            end else begin
                if(!empty) begin
                    next_state = DECODE;
                    rd_en      = 1;
                    write_dest = 0;
                end else begin
                    next_state = IDLE;
                    ready      = 1;
                    write_dest = 0;
                end
            end
        end
        default: begin 
            next_state = IDLE;
            wr_en      = 0;
            rd_en      = 0;
            write_dest = 0;
            ready      = 0;
        end
    endcase
end

endmodule