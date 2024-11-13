`timescale 1ns/1ps
module SystolicArray_tb;

reg clk;
reg reset;
reg [31 : 0] matrix_A;
reg [31 : 0] matrix_B;
wire [31 : 0] result;

SystolicArray #(
.ARRAY_SIZE(4),
.DATA_WIDTH(8)
) systolic_array (
.clk(clk),
.reset(reset),
.matrix_A(matrix_A),
.matrix_B(matrix_B),
.result(result)
);

initial begin
clk = 0;
reset = 1;
matrix_A = 32'h01020304;
/ / Example input
matrix_B = 32'h05060708;
/ / Example input
#5 reset = 0;
#50 $finish;
end

always #5 clk = ~clk;
endmodule