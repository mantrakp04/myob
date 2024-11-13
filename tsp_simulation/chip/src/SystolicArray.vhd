module SystolicArray #(
parameter ARRAY_SIZE = 4,
parameter DATA_WIDTH = 8
)(
input clk,
input reset,
input [ARRAY_SIZE * DATA_WIDTH - 1 : 0] matrix_A,
input [ARRAY_SIZE * DATA_WIDTH - 1 : 0] matrix_B,
output [ARRAY_SIZE * DATA_WIDTH - 1 : 0] result
);

/ / Declare wires to connect the PEs
wire [DATA_WIDTH - 1 : 0] in_A [0 : ARRAY_SIZE - 1][0 : ARRAY_SIZE - 1];
wire [DATA_WIDTH - 1 : 0] in_B [0 : ARRAY_SIZE - 1][0 : ARRAY_SIZE - 1];
wire [DATA_WIDTH - 1 : 0] out_A [0 : ARRAY_SIZE - 1][0 : ARRAY_SIZE - 1];
wire [DATA_WIDTH - 1 : 0] out_B [0 : ARRAY_SIZE - 1][0 : ARRAY_SIZE - 1];
wire [DATA_WIDTH - 1 : 0] pe_result [0 : ARRAY_SIZE - 1][0 : ARRAY_SIZE - 1];

/ / Instantiate PEs in a grid
genvar i, j;
generate
for (i = 0;
    i < ARRAY_SIZE;
    i = i + 1) begin : row
    for (j = 0;
        j < ARRAY_SIZE;
        j = j + 1) begin : col
        ProcessingElement #(.DATA_WIDTH(DATA_WIDTH)) PE (
        .clk(clk),
        .reset(reset),
        .in_A(in_A[i][j]),
        .in_B(in_B[i][j]),
        .out_A(out_A[i][j]),
        .out_B(out_B[i][j]),
        .result(pe_result[i][j])
        );
    end
end
endgenerate

/ / Connect input data and outputs
/ / (You will need to add logic to connect matrix_A and matrix_B to in_A and in_B)
endmodule