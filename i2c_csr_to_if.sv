module i2c_csr_to_if #(
  parameter DATA_W  = 16,
  parameter ADDR_W  = 5
)(
  input         rst_i,
  input         clk_i,

  avalon_mm_if  amm_if,
  i2c_if        i2c_if
);

logic [DATA_W-1:0]  readdata;
logic               readdatavalid;

logic [DATA_W-1:0]  mem [2**ADDR_W-1:0];

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    readdatavalid <= 1'b0;
  else
    readdatavalid <= amm_if.read;

always_ff @( posedge clk_i )
  if( amm_if.read )
    readdata <= mem[amm_if.address];

assign amm_if.readdatavalid = readdatavalid;
assign amm_if.readdata      = readdata;

endmodule

