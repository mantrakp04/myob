module ProcessingElement #(
parameter DATA_WIDTH = 8
)(
input clk,
input reset,
input [DATA_WIDTH - 1 : 0] in_A,
input [DATA_WIDTH - 1 : 0] in_B,
output reg [DATA_WIDTH - 1 : 0] out_A,
output reg [DATA_WIDTH - 1 : 0] out_B,
output reg [DATA_WIDTH - 1 : 0] result
);

reg [DATA_WIDTH - 1 : 0] accumulator;

always @(posedge clk or posedge reset) begin
if (reset) begin
    accumulator <= 0;
    result <= 0;
end else
begin
/ / Perform multiplication and accumulation
accumulator <= accumulator + (in_A * in_B);
result <= accumulator;

/ / Pass inputs to the next PE
out_A <= in_A;
out_B <= in_B;
end
end
endmodule