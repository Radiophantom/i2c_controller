module i2c_mem_model(
  input clk_i,

  inout sda_io,
  inout scl_io
);

bit [6:0] address  = 7'b0101010;
bit       cmd_type;

task automatic run();

initial
  begin
    fork
      run();
    join_none
  end

endmodule : i2c_mem_model

