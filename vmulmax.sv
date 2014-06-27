/* Pipelined Vector Multiply and Compute Maximum */
module testbench_vmulmax();

timeunit 10ns;
timeprecision 1ns;

logic clock = 1'b0, resetn = 1'b0;

logic [1:0][15:0] a, x;
logic [15:0] y;

vmulmax #(.VECTOR_SIZE(2), .INT_SIZE(16)) u0(.*);

always #1 clock = ~clock;

initial begin
  $display("Starting");
  
  a = '0;
  x = '0;
  
  #1 resetn = 1'b1;
  
  #2 a[0] = 16'd1;
  x[0] = 16'd4;
  
  #2 a[1] = 16'd4;
  x[1] = 16'd2;
end

endmodule

module vmulmax #(
  parameter VECTOR_SIZE = 16,
  parameter INT_SIZE = 16
)(
  input logic clock, resetn,
  input logic [VECTOR_SIZE-1:0][INT_SIZE-1:0] a, x,
  output logic [INT_SIZE-1:0] y
);

logic [VECTOR_SIZE-1:0][INT_SIZE-1:0] mult_reg;

// Multiply stage
vvmul #(.VECTOR_SIZE(VECTOR_SIZE), .INT_SIZE(INT_SIZE)) p0 (.clock, .resetn, .a, .x, .y(mult_reg));

// Multi-stage max
vreducemax #(.VECTOR_SIZE(VECTOR_SIZE), .INT_SIZE(INT_SIZE)) p1 (.clock, .resetn, .x(mult_reg), .y);

endmodule
