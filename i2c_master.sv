module i2c_controller_engine (
  i2c_if        i2c_if,

  input         rst_i,
  input         clk_i,

  // general signals
  output         cmd_valid_o,
  input        ready_i,

  // master service signals
  output         start_send_o,
  output         stop_send_o,

  // master write signals
  output         byte_send_o,
  output   [7:0] byte_o,

  // master read signals
  output         byte_rcv_o,
  output         ack_en_o,

  //output        byte_valid_o,
  //output        start_rcv_o,
  //output        stop_rcv_o,
  input        ack_received_i,
  input  [7:0] byte_i
);

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    state <= IDLE_S;
  else
    state <= next_state;

always_comb
  begin
    next_state = state;
    case( state )
      IDLE_S:
        begin
          if( i2c_cfg_if.periph_en && i2c_cfg_if.start_bit_en )
            next_state = START_S;
        end

      SEND_START_S:
        begin
          if( arb_loss )
            next_state == IDLE_S;
          else
            if( i2c_cfg_if.start_bit_en )
              next_state = SEND_BYTE_S;
        end

      SEND_BYTE_S:
        begin
          if( send_byte_cnt == 8 )
            if( i2c_cfg_if.transaction_mode )
              next_state = READ_BYTE_S;
            else
              next_state = WRITE_BYTE_S;
        end

      READ_BYTE_S:
        begin
          if( rcv_byte_cnt == 8 )
            if( i2c_cfg_if.last_byte )
              next_state = STOP_S;
            else
              next_state = ACK_SEND_S;
        end

      WRITE_BYTE_S:
        begin
          if( wr_byte_cnt == 8 )
            next_state = ACK_CHECK_S;
        end

      ACK_SEND_S:
        begin
          if( ack_cnt == 100 )
            next_state = READ_BYTE_S;
        end

      ACK_CHECK_S:
        begin
          if( ack_check_cnt_timeout )
            next_state = STOP_S;
          else
            if( ack_check_ok )
              next_state = WRITE_BYTE_S;
        end

      STOP_S:
        begin
          if( stop_ok )
            next_state = IDLE_S;
        end

      default: next_state = IDLE_S;
    endcase
  end

always_ff @( posedge clk_i )
  if( rcv_en_stb )
    receive_shift_reg <= { receive_shift_reg[6:0], sda_io };

always_ff @( posedge clk_i )
  if( load_trans )
    trans_shift_reg <= i2c_cfg_if.data;
  else
    if( trans_en_stb )
      trans_shift_reg <= trans_shift_reg << 1;

always_ff @( posedge clk_i )
  if( start_clocking )
    scl <= 
  if( master_state )
    scl <= 


endmodule : i2c_controller

