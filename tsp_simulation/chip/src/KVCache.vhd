module KVCache #(
parameter CACHE_DEPTH = 1024,
parameter VECTOR_WIDTH = 8
)(
input clk,
input reset,
input write_enable,
input [9 : 0] read_index, // Assuming CACHE_DEPTH <= 1024
input [VECTOR_WIDTH - 1 : 0] key_in,
input [VECTOR_WIDTH - 1 : 0] value_in,
output reg [VECTOR_WIDTH - 1 : 0] key_out,
output reg [VECTOR_WIDTH - 1 : 0] value_out
);

/ / Memory arrays for keys and values
reg [VECTOR_WIDTH - 1 : 0] key_cache [0 : CACHE_DEPTH - 1];
reg [VECTOR_WIDTH - 1 : 0] value_cache [0 : CACHE_DEPTH - 1];
reg [9 : 0] write_index;
/ / Index for writing to the cache

always @(posedge clk or posedge reset) begin
if (reset) begin
    write_index <= 0;
end else
if (write_enable) begin
    / / Write key and value to the cache
    key_cache[write_index] <= key_in;
    value_cache[write_index] <= value_in;
    write_index <= write_index + 1;
end
end

always @(posedge clk) begin
/ / Read key and value from the cache
key_out <= key_cache[read_index];
value_out <= value_cache[read_index];
end
endmodule