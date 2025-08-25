`timescale 1ns/1ps
`include "MIPS.v"
module DUT();
reg clk1, clk2;
integer i, k;
MIPS m1(
    .clk1(clk1),
    .clk2(clk2)
);
initial begin
    clk1 = 0; clk2 = 0;
    repeat (20) begin
        #5 clk1 = 1; #5 clk1 = 0;
        #5 clk2 = 1; #5 clk2 = 0;
    end
end
initial begin
    $dumpfile("MIPS_test.vcd");
    $dumpvars(0,DUT);

    #300 $finish;
end
initial begin
    for(k = 0; k<32; k = k+1)begin
        m1.reg_bank[k] = k;
    end
    m1.mem[0] = 32'h2801000A;
    m1.mem[1] = 32'h28020014;
    m1.mem[2] = 32'h28030019;
    m1.mem[3] = 32'h0CE77800;
    m1.mem[4] = 32'h0CE77800;
    m1.mem[5] = 32'h00222000;
    m1.mem[6] = 32'h0CE77800;
    m1.mem[7] = 32'h00832800;
    m1.mem[8] = 32'hFC000000;

    m1.HALTED = 0;
    m1.PC = 0;
    m1.TAKEN_BRANCH = 0;

    #280
    for(i = 0; i<6; i++)
    $display("R%d - %2d", i, m1.reg_bank[i]);
end
endmodule