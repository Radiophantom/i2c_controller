`timescale 1ns/1ps

module i2c_bit_ctrl_tb;

bit clk;
bit rst;

bit cmd_valid_i;
bit ready_o;

bit start_send_i;
bit stop_send_i;
bit ack_send_i;
bit bit_send_i;

bit bit_i;

bit cmd_valid_o;

bit start_rcv_o;
bit stop_rcv_o;
bit ack_rcv_o;
bit bit_rcv_o;

bit bit_o;

bit busy_rcv_o;

logic sda_io;
logic scl_io;

task automatic send_byte(
  input bit [7:0] data
);
  send_start();
  for( int bit_num = 0; bit_num < 8; bit_num++ )
    send_bit( data[bit_num] );
  send_stop();
endtask : send_byte

task automatic send_start();
  cmd_valid_i   <= 1'b1;
  start_send_i  <= 1'b1;
  do
    @( posedge clk );
  while( ~ready_o );
  start_send_i  <= 1'b0;
  cmd_valid_i   <= 1'b0;
endtask : send_start

task automatic send_stop();
  cmd_valid_i <= 1'b1;
  stop_send_i <= 1'b1;
  do
    @( posedge clk );
  while( ~ready_o );
  stop_send_i <= 1'b0;
  cmd_valid_i <= 1'b0;
endtask : send_stop

task automatic send_bit( bit bit_data );
  cmd_valid_i <= 1'b1;
  bit_send_i  <= 1'b1;
  bit_i       <= bit_data;
  do
    @( posedge clk );
  while( ~ready_o );
  bit_send_i  <= 1'b0;
  cmd_valid_i <= 1'b0;
endtask : send_bit

task automatic send_ack();
  cmd_valid_i <= 1'b1;
  ack_send_i  <= 1'b1;
  do
    @( posedge clk );
  while( ~ready_o );
  ack_send_i  <= 1'b0;
  cmd_valid_i <= 1'b0;
endtask : send_ack

endmodule : i2c_bit_ctrl_tb

