/* Pipelined Vector Multiply and Compute Maximum */
module testbench_vmulmax();

timeunit 10ns;
timeprecision 1ns;

logic clock = 1'b0, resetn = 1'b0;

logic [15:0][15:0] a, x;
logic [15:0] y;

vmulmax u0(.*);

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

// Multiply stage 1
logic [VECTOR_SIZE-1:0][INT_SIZE-1:0] mult, mult_reg;

genvar i;
generate
  for (i = 0; i < VECTOR_SIZE; i++) begin
    always_comb mult[i] = a[i] * x[i];
  end
endgenerate

always_ff @ (posedge clock or negedge resetn) begin
  if (~resetn)
    mult_reg = '0;
  else
    mult_reg = mult;
end

genvar j, k;
generate
  for (j = 0; j < $clog2(VECTOR_SIZE); j++) begin : level

    // Max stage k
    logic [VECTOR_SIZE/(2<<j) - 1:0][INT_SIZE-1:0] max, max_reg;

    for (k = 0; k < VECTOR_SIZE/(2<<j); k++) begin
      if (j == 0)
        always_comb max[k] = mult_reg[2*k] < mult_reg[2*k+1] ? mult_reg[2*k+1] : mult_reg[2*k];
      else
        always_comb max[k] = level[j-1].max_reg[2*k] < level[j-1].max_reg[2*k+1] ? level[j-1].max_reg[2*k+1] : level[j-1].max_reg[2*k];
    end

    always_ff @ (posedge clock or negedge resetn) begin
      if (~resetn)
        max_reg = '0;
      else
        max_reg = max;
    end
  end
endgenerate

assign y = level[$clog2(VECTOR_SIZE)-1].max_reg[0];

endmodule
