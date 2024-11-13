`timescale 1ns/1ps
module KVCache_tb;

reg clk;
reg reset;
reg write_enable;
reg [9 : 0] read_index;
reg [7 : 0] key_in;
reg [7 : 0] value_in;
wire [7 : 0] key_out;
wire [7 : 0] value_out;

KVCache #(
.CACHE_DEPTH(1024),
.VECTOR_WIDTH(8)
) kv_cache (
.clk(clk),
.reset(reset),
.write_enable(write_enable),
.key_in(key_in),
.value_in(value_in),
.read_index(read_index),
.key_out(key_out),
.value_out(value_out)
);

initial begin
clk = 0;
reset = 1;
write_enable = 0;
key_in = 8'hAA;
value_in = 8'hBB;
read_index = 0;
#5 reset = 0;

/ / Write to cache
#10 write_enable = 1;