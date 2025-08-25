`timescale 1ns/1ps
`include "MIPS.v"
module DUT();
reg clk1, clk2;
integer i;
MIPS m1(
    .clk1(clk1),
    .clk2(clk2)
);
initial begin
    $dumpfile("MIPS_factorial.vcd");
    $dumpvars(0, DUT);
    #5000 $finish;
end
initial begin
    clk1 = 0; clk2 = 0; m1.PC = 0; m1.HALTED = 0; m1.mem[200] = 6;
end
always begin
        #5 clk1 = 1; #5 clk1 = 0;
        #5 clk2 = 1; #5 clk2 = 0;
end
initial begin
    for(i = 0; i<32; i = i+1) begin
        m1.reg_bank[i] = i;
    end
    m1.mem[0] = 32'h280100C8;
    m1.mem[1] = 32'h28030001;

    m1.mem[2] = 32'h0CE77800;
    m1.mem[3] = 32'h0CE77800;

    m1.mem[4] = 32'h20220000;

    m1.mem[5] = 32'h0CE77800;
    m1.mem[6] = 32'h0CE77800;
    m1.mem[7] = 32'h0CE77800;

    m1.mem[8] = 32'h14431800;
    m1.mem[9] = 32'h2C420001;

    m1.mem[10] = 32'h0CE77800;
    m1.mem[11] = 32'h0CE77800;

    m1.mem[12] = 32'h3440FFFB;

    m1.mem[13] = 32'h0CE77800;
    m1.mem[14] = 32'h0CE77800;
    m1.mem[15] = 32'h2423FFFE;
    m1.mem[16] = 32'hFC000000;
end
initial begin
$monitor("R1 = %d, R2 = %d, R3 = %d, TIME: = ",m1.reg_bank[1], m1.reg_bank[2], m1.reg_bank[3],$time);
#2000 $display("content in 198", m1.mem[198]);
end
endmodule