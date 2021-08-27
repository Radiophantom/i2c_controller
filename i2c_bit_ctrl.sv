module i2c_bit_ctrl (
  input   rst_i,
  input   clk_i,

  input   cmd_valid_i,
  output  ready_o,

  input   start_send_i,
  input   stop_send_i,
  input   ack_send_i,
  input   bit_send_i,
  //input   rcv_mode_i,

  input   bit_i,

//  output arb_lost_o,
  
  output  cmd_valid_o,

  output  start_rcv_o,
  output  stop_rcv_o,
  output  ack_rcv_o,
  output  bit_rcv_o,

  output  bit_o,

  output  busy_rcv_o,

  inout   sda_io,
  inout   scl_io
);

//************************************************************
// Localparameters calculate and assign
//************************************************************

localparam START_TSU  = 600;
localparam STOP_TSU   = 600;

localparam GEN_TSU    = 100;
localparam GEN_TH     = 100;

//************************************************************
// Bidirectional line control
//************************************************************

assign scl_io = ( scl_drive_en ) ? ( scl ) : ( 1'bZ );
assign sda_io = ( sda_drive_en ) ? ( sda ) : ( 1'bZ );

//************************************************************
// State machine
//************************************************************

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
          if( cmd_valid_i )
            if( start_send_i )
              next_state = SEND_START_S;
            else
              if( stop_send_i )
                next_state = SEND_STOP_S;
              else
                if( bit_send_i )
                  next_state = SEND_BIT_S;
                else
                  if( ack_send_i )
                    next_state = SEND_ACK_S;
                //else
                //  if( bit_rcv_i )
                //    next_state = RCV_BIT_S;
        end

      SEND_START_S:
        begin
          if( send_flag )
            next_state = IDLE_S;
        end

      SEND_STOP_S:
        begin
          if( send_flag )
            next_state = IDLE_S;
        end

      SEND_BIT_S:
        begin
          if( send_flag )
            next_state = IDLE_S;
        end

      SEND_ACK_S:
        begin
          if( send_flag )
            next_state = IDLE_S;
        end

      /*
      RCV_START_S:
        begin
          if( rcv_flag )
            next_state = IDLE_S;
        end

      RCV_STOP_S:
        begin
          if( rcv_flag )
            next_state = IDLE_S;
        end

      RCV_ACK_S:
        begin
          if( rcv_flag )
            next_state = IDLE_S;
        end

      RCV_BIT_S:
        begin
          if( rcv_flag )
            next_state = IDLE_S;
        end
      */

      default: next_state = IDLE_S;
    endcase
  end

//************************************************************
// SDA line control logic
//************************************************************

always_ff @( posedge scl )
  if( state == RCV_BIT_S )
    sda_in <= sda_io;

always_ff @( posedge clk_i )
  //if( state == IDLE_S && cmd_valid_i && stop_send_i )
  if( state == SEND_STOP_S && scl_toggle_en )
    sda_cnt <= STOP_TSU;
  else
    if( sda_cnt_en )
      sda_cnt <= sda_cnt - 1'b1;

always_ff @( posedge clk_i )
  //if( state == IDLE_S && cmd_valid_i && stop_send_i )
  if( state == SEND_STOP_S && scl_toggle_en )
    sda_cnt_en <= 1'b1;
  else
    if( sda_cnt == 1 )
      sda_cnt_en <= 1'b0;

always_ff @( posedge clk_i )
  if( state == IDLE_S && cmd_valid_i )
    begin
      if( start_send_i || ack_send_i )
        sda <= 1'b0;
      else
        if( bit_send_i )
          sda <= bit_i;
    end
  else
    if( state == SEND_STOP_S && sda_low_en )
      sda <= 1'b1;

assign sda_low_en = ( sda_cnt == 1 );

//************************************************************
// SCL line control logic
//************************************************************

always_ff @( posedge clk_i )
  if( state == IDLE_S && cmd_valid_i )
    begin
      if( start_send_i )
        scl_cnt <= START_CLK;
      else
        if( stop_send_i )
          scl_cnt <= STOP_CLK;
        else
          if( ack_send_i || bit_send_i )
            scl_cnt <= GEN_CLK;
    end
  else
    if( scl_cnt_en )
      if( scl_reload )
        scl_cnt <= '0;
      else
        scl_cnt <= scl_cnt - 1'b1;

always_ff @( posedge clk_i )
  if( state == IDLE_S && cmd_valid_i && ~stop_send_i )
    scl_cnt_en <= 1'b1;
  else
    if( state == SEND_START_S && scl_cnt == 1 )
      scl_cnt_en <= 1'b0;
    else
      if( state != SEND_START_S && scl_cnt == 1 && scl )
        scl_cnt_en <= 1'b0;

assign scl_low_en     = ( state == SEND_START_S );
assign scl_high_en    = ( state == SEND_STOP_S  );

assign scl_toggle_en  = ( scl_cnt == 1 );

always_ff @( posedge clk_i )
  if( scl_toggle_en )
    if( scl_high_en )
      scl <= 1'b1;
    else
      if( scl_low_en )
        scl <= 1'b0;
      else
        scl <= ~scl;

//********************************************
// General control logic
//********************************************

//TODO Clock stretching support add
//assign scl_drive_en = ( state == SEND_START_S || state == SEND_STOP_S || state == SEND_ACK_S || state == SEND_BIT_S );
assign scl_drive_en = 1'b1;
assign sda_drive_en = ( state == SEND_START_S || state == SEND_STOP_S || state == SEND_ACK_S || state == SEND_BIT_S );

always_ff @( posedge clk_i )
  if( state != SEND_STOP_S )
    send_flag_load <= scl_toggle_en && scl;
  else
    send_flag_load <= scl_toggle_en && ~scl;
//case( state )
//  SEND_START_S: send_flag <= scl_toggle_en && scl;
//  SEND_STOP_S:  send_flag <= scl_toggle_en && scl;
//  SEND_ACK_S:
//  SEND_BIT_S:
//send_flag <= scl_io

always_ff @( posedge clk_i )
  if( send_flag_load )
    th_cnt <= GEN_TH;
  else
    if( th_cnt != 0 )
      th_cnt <= th_cnt - 1'b1;

always_ff @( posedge clk_i )
  send_flag <= ( th_cnt == 1 );

endmodule : i2c_bit_ctrl

