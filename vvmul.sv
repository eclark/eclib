/* Latched Vector Vector Multiply */
module testbench_vvmul();

timeunit 10ns;
timeprecision 1ns;

logic clock = 1'b0, resetn = 1'b0;

logic [15:0][15:0] a, x;
logic [15:0] y;

vmulmax u0(.*);

always #1 clock = ~clock;

initial begin
  a = '0;
  x = '0;
  
  #1 resetn = 1'b1;
  
  #2 a[0] = 16'd1;
  x[0] = 16'd4;
  
  #2 a[1] = 16'd4;
  x[1] = 16'd2;
end

endmodule

module vvmul #(
  parameter VECTOR_SIZE = 16,
  parameter INT_SIZE = 16
)(
  input logic clock, resetn,
  input logic [VECTOR_SIZE-1:0][INT_SIZE-1:0] a, x,
  output logic [VECTOR_SIZE-1:0][INT_SIZE-1:0] y
);

// Multiply stage
logic [VECTOR_SIZE-1:0][INT_SIZE-1:0] mult, mult_reg;

genvar i;
generate
  for (i = 0; i < VECTOR_SIZE; i++) begin
    always_comb mult[i] = a[i] * x[i];
  end
endgenerate

always_ff @ (posedge clock or negedge resetn) begin
  if (~resetn)
    y = '0;
  else
    y = mult;
end

endmodule
