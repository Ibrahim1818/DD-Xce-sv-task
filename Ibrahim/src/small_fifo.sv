module small_fifo #(
    parameter DEPTH        = 4, 
    parameter WIDTH_PACKET = 13
) (
    input  logic                    clk,       
    input  logic                    rst,   
    input  logic                    wr_en,     
    input  logic [WIDTH_PACKET-1:0] wr_data,   
    input  logic                    rd_en,   
    output logic [WIDTH_PACKET-1:0] rd_data,   
    output logic                    full,      
    output logic                    empty      
);

logic [WIDTH_PACKET-1:0] fifo_mem [0:DEPTH-1]; // Memory to store the 13-bit packets
logic [$clog2(DEPTH):0] wr_ptr, rd_ptr; // Write and read pointers
logic [$clog2(DEPTH):0] fifo_count;     // Number of elements in the FIFO

// FIFO status flags
assign full  = (fifo_count == DEPTH);
assign empty = (fifo_count == 0);

// Writing to the FIFO
always_ff @(posedge clk or negedge rst) begin
    if (!rst) begin
        wr_ptr           <= 0;
    end else if (wr_en && !full) begin
        fifo_mem[wr_ptr] <= wr_data;
        wr_ptr           <= wr_ptr + 1;
    end
end
// Reading from the FIFO
always_ff @(posedge clk or negedge rst) begin
    if (!rst) begin
        rd_ptr  <= 0;
    end else if (rd_en && !empty) begin
        rd_data <= fifo_mem[rd_ptr];
        rd_ptr  <= rd_ptr + 1;
    end
end
// FIFO count logic
always_ff @(posedge clk or negedge rst) begin
    if (!rst) begin
        fifo_count <= 0;
    end else begin
        case ({wr_en && !full, rd_en && !empty})
            2'b01: fifo_count   <= fifo_count - 1;
            2'b10: fifo_count   <= fifo_count + 1;
            default: fifo_count <= fifo_count;
        endcase
    end
end
endmodule
