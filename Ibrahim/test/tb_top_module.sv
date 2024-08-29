module tb_top_module;

parameter WIDTH_TYPE    = 2;
parameter WIDTH_PAYLOAD = 8;
parameter WIDTH_PACKET  = 13;
parameter BURST_SIZE    = 1;

// Testbench signals
logic clk;
logic rst;
logic [WIDTH_TYPE-1:0] dest_addr, pack_type;
logic [WIDTH_PAYLOAD-1:0] payload;
logic eop;
logic [WIDTH_PACKET-1:0] destination_out;

top_module #(
    .WIDTH_TYPE(WIDTH_TYPE),
    .WIDTH_PAYLOAD(WIDTH_PAYLOAD),
    .WIDTH_PACKET(WIDTH_PACKET),
    .BURST_SIZE(BURST_SIZE)
) dut (
    .clk(clk),
    .rst(rst),
    .dest_addr(dest_addr),
    .pack_type(pack_type),
    .payload(payload),
    .eop(eop),
    .destination_out(destination_out)
);

// Clock generation task
initial begin
    clk = 0;
    forever #5 clk = ~clk; // 10ns period
end

// Reset logic task
task reset_sequence;
    begin
        rst = 0; // Assert reset
        #55;
        rst = 1; // Deassert reset
    end
endtask

// Initialization task
task init_sequence;
    begin
        rst = 1;
        dest_addr = 2'b00;
        pack_type = 2'b00;
        payload   = 8'h00;
        eop       = 0;
    end
endtask

// Drive inputs task
task drive_inputs(input [1:0] d_addr, input [1:0] p_type, input [7:0] p_data, input logic eop_i);
    begin
        dest_addr = d_addr;
        pack_type = p_type;
        payload   = p_data;
        eop       = eop_i;
    end
endtask

// Monitor task
task monitor_output;
    begin
        if(destination_out == payload) begin
            $display("PASS");
        end
        else begin
            $display("FAIL");
        end
    end
endtask

// Test sequence
initial begin
    init_sequence();
    reset_sequence();
    
    test_sequence();
    repeat(10) @(posedge clk);
    
    $finish;
end

// Test sequence task
task test_sequence;
    begin
        drive_inputs(2'b01, 2'b01, 8'hAB, 1'b1); // Test Case 1
        monitor_output();
        repeat(10) @(posedge clk);

        drive_inputs(2'b10, 2'b10, 8'hCD, 1'b1); // Test Case 2
        monitor_output();
        
        repeat($random % 20) @(posedge clk);
        drive_inputs(2'b11, 2'b11, 8'hEF, 1'b1); // Test Case 3
        monitor_output();
        repeat($random % 10) @(posedge clk);
    end
endtask
    
    // VCD Dump
    initial begin
        $dumpfile("packet_noc.vcd");
        $dumpvars(0);
    end
    
    endmodule
    