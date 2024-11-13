module TransformerAccelerator #(
parameter ARRAY_SIZE = 4,
parameter DATA_WIDTH = 8,
parameter CACHE_DEPTH = 1024,
parameter VECTOR_WIDTH = 8
)(
input clk,
input reset,
input [ARRAY_SIZE * DATA_WIDTH - 1 : 0] matrix_A,
input [ARRAY_SIZE * DATA_WIDTH - 1 : 0] matrix_B,
input write_enable,
input [VECTOR_WIDTH - 1 : 0] key_in,
input [VECTOR_WIDTH - 1 : 0] value_in,
input [9 : 0] read_index,
output [ARRAY_SIZE * DATA_WIDTH - 1 : 0] result,
output [VECTOR_WIDTH - 1 : 0] key_out,
output [VECTOR_WIDTH - 1 : 0] value_out
);

/ / Instantiate the systolic array
SystolicArray #(
.ARRAY_SIZE(ARRAY_SIZE),
.DATA_WIDTH(DATA_WIDTH)
) systolic_array_inst (
.clk(clk),
.reset(reset),
.matrix_A(matrix_A),
.matrix_B(matrix_B),
.result(result)
);

/ / Instantiate the KV cache
KVCache #(
.CACHE_DEPTH(CACHE_DEPTH),
.VECTOR_WIDTH(VECTOR_WIDTH)
) kv_cache_inst (
.clk(clk),
.reset(reset),
.write_enable(write_enable),
.key_in(key_in),
.value_in(value_in),
.read_index(read_index),
.key_out(key_out),
.value_out(value_out)
);
endmodule