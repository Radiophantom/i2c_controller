`timescale 1ns/1ps

module i2c_bit_ctrl_tb;

bit clk;
bit rst;

bit cmd_valid_i;
bit ready_o;

bit start_send_i;
bit stop_send_i;

bit       byte_send_i;
bit [7:0] byte_i;

bit byte_rcv_i;
bit ack_en_i;

bit ack_received_o;

bit [7:0] byte_o;

bit ack_rcv;
bit [7:0] byte_rcv;

wire sda_io_module;
wire scl_io_module;

pullup ( pull1 ) sda_tb ( sda_io_module );
pullup ( pull1 ) scl_tb ( scl_io_module );

i2c_transaction_ctrl #(
  .REF_CLK_PERIOD( 10 )
) dut (
  .rst_i        ( rst ),
  .clk_i        ( clk ),

  .cmd_valid_i  ( cmd_valid_i ),
  .ready_o      ( ready_o ),

  .start_send_i ( start_send_i ),
  .stop_send_i  ( stop_send_i ),

  .byte_send_i  ( byte_send_i ),
  .byte_i       ( byte_i ),

  .byte_rcv_i   ( byte_rcv_i ),
  .ack_en_i     ( ack_en_i ),

  .ack_received_o( ack_received_o ),
  .byte_o       ( byte_o ),

  .sda_io       ( sda_io_module ),
  .scl_io       ( scl_io_module )
);

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

task automatic send_byte(
  input   bit [7:0] byte_data,
  output  bit       ack
);
  cmd_valid_i <= 1'b1;
  byte_send_i <= 1'b1;
  byte_i      <= byte_data;
  do
    @( posedge clk );
  while( ~ready_o );
  byte_send_i <= 1'b0;
  cmd_valid_i <= 1'b0;
  do
    @( posedge clk );
  while( ~ready_o );
  ack = ack_received_o;
endtask : send_byte

task automatic rcv_byte(
  input   bit       ack_en,
  output  bit [7:0] byte_data
);
  cmd_valid_i <= 1'b1;
  byte_rcv_i  <= 1'b1;
  byte_i      <= byte_data;
  ack_en_i    <= ack_en;
  do
    @( posedge clk );
  while( ~ready_o );
  byte_rcv_i  <= 1'b0;
  cmd_valid_i <= 1'b0;
  ack_en_i    <= 1'b0;
  do
    @( posedge clk );
  while( ~ready_o );
  byte_data = byte_o;
endtask : rcv_byte

initial
  begin
    fork
      forever #5 clk = ~clk;
    join_none
    rst <= 1'b1;
    @( posedge clk );
    rst <= 1'b0;

  send_start();
  send_byte( 8'hAA, ack_rcv );
  send_stop();
  do
    @( posedge clk );
  while( ~ready_o );

  send_start();
  send_byte( 8'hFF, ack_rcv );
  send_start();
  rcv_byte( 1'b1, byte_rcv );
  rcv_byte( 1'b0, byte_rcv );
  send_stop();
  do
    @( posedge clk );
  while( ~ready_o );

  $display("Everything is OK");
  $stop();
  end
endmodule : i2c_bit_ctrl_tb

