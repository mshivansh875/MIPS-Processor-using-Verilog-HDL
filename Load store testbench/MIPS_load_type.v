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
    $dumpfile("MIPS_load_type.vcd");
    $dumpvars(0, DUT);
    #300 $finish;
end
initial begin
    clk1 = 0; clk2 = 0; m1.mem[120] = 32'h00000011;
    m1.PC = 0; m1.HALTED = 0;
    repeat (20) begin
        #5 clk1 = 1; #5 clk1 = 0;
        #5 clk2 = 1; #5 clk2 = 0;
    end
end
initial begin
    for(i = 0; i<32; i = i+1) begin
        m1.reg_bank[i] <= i;
    end
    m1.mem[0] = 32'h28010078;
    m1.mem[1] = 32'h0CE77800;
    m1.mem[2] = 32'h0CE77800;
    m1.mem[3] = 32'h0CE77800;
    m1.mem[4] = 32'h20220000;
    m1.mem[5] = 32'h0CE77800;
    m1.mem[6] = 32'h0CE77800;
    m1.mem[7] = 32'h0CE77800;
    m1.mem[8] = 32'h24220001;
    m1.mem[9] = 32'hFC000000;
    #280;
    $display("R1 = %3d, R2 = %d", m1.reg_bank[1], m1.reg_bank[2]);
    $display("The content of 120 address is = %d and of 121 = %d", m1.mem[120], m1.mem[121]);
end
endmodule