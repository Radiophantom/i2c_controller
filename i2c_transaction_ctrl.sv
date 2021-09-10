`define SIM

module i2c_transaction_ctrl #(
  parameter REF_CLK_PERIOD = 1_000
)(
  input         rst_i,
  input         clk_i,

  // general signals
  input         cmd_valid_i,
  output        ready_o,

  // master service signals
  input         start_send_i,
  input         stop_send_i,

  // master write signals
  input         byte_send_i,
  input   [7:0] byte_i,

  // master read signals
  input         byte_rcv_i,
  input         ack_en_i,

  //output        byte_valid_o,
  //output        start_rcv_o,
  //output        stop_rcv_o,
  output        ack_received_o,
  output  [7:0] byte_o,

  // external interface signals
  inout         sda_io,
  inout         scl_io
);

//************************************************************
// Localparameters calculate and assign
//************************************************************

localparam START_TSU  = 600/REF_CLK_PERIOD    + ( 600%REF_CLK_PERIOD    != 0 );
localparam STOP_TSU   = 600/REF_CLK_PERIOD    + ( 600%REF_CLK_PERIOD    != 0 );

localparam SCL_LOW    = 10_000/REF_CLK_PERIOD + ( 10_000%REF_CLK_PERIOD != 0 );
localparam SCL_HIGH   = 10_000/REF_CLK_PERIOD + ( 10_000%REF_CLK_PERIOD != 0 );
localparam SCL_PERIOD = SCL_LOW + SCL_HIGH;

localparam SCL_CNT_W  = ( SCL_LOW > SCL_HIGH ) ?  ( $clog2( SCL_LOW   ) ):
                                                  ( $clog2( SCL_HIGH  ) );
localparam GEN_TSU    = 100/REF_CLK_PERIOD    + ( 100%REF_CLK_PERIOD    != 0 );
localparam GEN_TH     = 100/REF_CLK_PERIOD    + ( 100%REF_CLK_PERIOD    != 0 );

//************************************************************
// Variables declaration
//************************************************************

logic                 scl;
logic                 scl_drive_en, sda_drive_en;
logic [SCL_CNT_W-1:0] scl_cnt;
logic                 scl_reload_en;

logic                 sda;
logic [7:0]           sda_in;
logic [3:0]           byte_rcv_cnt, byte_sent_cnt;

logic                 sda_read, sda_write, sda_shift_en;

logic [7:0]           trans_byte_shift_reg;

logic                 ack_en_flag;
logic                 send_flag;

enum {
  IDLE_S,
  SEND_START_S,
  SEND_STOP_S,
  SEND_BYTE_S,
  SEND_ACK_S,
  CHECK_ACK_S,
  RCV_BYTE_S
} state, next_state;

//************************************************************
// Bidirectional line control
//************************************************************

`ifdef SIM

  logic sda_io_tmp;
  logic scl_io_tmp;

  buf ( highz1, strong0 ) sda_buf ( sda_io_tmp, sda );
  buf ( highz1, strong0 ) scl_buf ( scl_io_tmp, scl );

  assign scl_io = ( scl_drive_en ) ? ( scl_io_tmp ) : ( 1'bZ );
  assign sda_io = ( sda_drive_en ) ? ( sda_io_tmp ) : ( 1'bZ );

`else

  assign scl_io = ( scl_drive_en ) ? ( scl ) : ( 1'bZ );
  assign sda_io = ( sda_drive_en ) ? ( sda ) : ( 1'bZ );

`endif

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
            case( { start_send_i, stop_send_i, byte_send_i, byte_rcv_i } )
              4'b1000: next_state = SEND_START_S;
              4'b0100: next_state = SEND_STOP_S;
              4'b0010: next_state = SEND_BYTE_S;
              4'b0001: next_state = RCV_BYTE_S;
            endcase
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

      SEND_BYTE_S:
        begin
          if( send_flag && byte_sent_cnt == 8 )
            next_state = CHECK_ACK_S;
        end

      CHECK_ACK_S:
        begin
          if( send_flag )
            next_state = IDLE_S;
        end

      RCV_BYTE_S:
        begin
          if( send_flag && byte_rcv_cnt == 8 )
            next_state = SEND_ACK_S;
        end

      SEND_ACK_S:
        begin
          if( send_flag )
            next_state = IDLE_S;
        end

      default: next_state = IDLE_S;
    endcase
  end

//************************************************************
// SDA line input control logic
//************************************************************

always_ff @( posedge scl )
  if( state == RCV_BYTE_S || state == CHECK_ACK_S )
    if( sda_read )
      sda_in <= { sda_in[6:0], sda_io };

always_ff @( posedge clk_i )
  if( state == IDLE_S && cmd_valid_i && byte_rcv_i )
    byte_rcv_cnt <= '0;
  else
    if( sda_read )
      byte_rcv_cnt <= byte_rcv_cnt + 1'b1;

assign ack_received_o = sda_in[0];
assign byte_o         = sda_in;

//************************************************************
// SDA line output control logic
//************************************************************

always_ff @( posedge clk_i )
  if( state == IDLE_S && cmd_valid_i && byte_rcv_i )
    ack_en_flag <= ack_en_i;

always_ff @( posedge clk_i )
  if( state == IDLE_S && cmd_valid_i && byte_send_i )
    trans_byte_shift_reg <= byte_i;
  else
    if( sda_shift_en )
      trans_byte_shift_reg <= trans_byte_shift_reg << 1;

assign sda_shift_en = state == SEND_BYTE_S && sda_write;

always_ff @( posedge clk_i )
  if( state == IDLE_S && cmd_valid_i && byte_send_i )
    byte_sent_cnt <= '0;
  else
    if( sda_write )
      byte_sent_cnt <= byte_sent_cnt + 1'b1;

always_ff @( posedge clk_i )
  case( state )
    SEND_START_S:
      begin
        if( scl && sda_read )
          sda <= 1'b0;
        else
          if( ~scl && sda_write )
            sda <= 1'b1;
      end

    SEND_STOP_S:
      begin
        if( ~scl && sda_write )
          sda <= 1'b0;
        else
          if( scl && sda_read )
            sda <= 1'b1;
      end

    SEND_BYTE_S:
      begin
        if( sda_write )
          sda <= trans_byte_shift_reg[7];
      end

    SEND_ACK_S:
      begin
        if( sda_write )
          if( ack_en_flag )
            sda <= 1'b0;
          else
            sda <= 1'b1;
      end

  endcase

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    sda_drive_en <= 1'b0;
  else
    if( sda_write )
      if( state == CHECK_ACK_S || state == RCV_BYTE_S )
        sda_drive_en <= 1'b0;
      else
        sda_drive_en <= 1'b1;
    else
      if( sda_read )
        if( state == SEND_START_S )
          sda_drive_en <= 1'b1;

//************************************************************
// SCL line control logic
//************************************************************

always_ff @( posedge clk_i )
  case( state )
    IDLE_S:
      begin
        if( cmd_valid_i )
          if( start_send_i && scl )
            scl_cnt <= SCL_HIGH;
          else
            scl_cnt <= SCL_LOW;
      end

    SEND_BYTE_S:
      begin
        if( scl_reload_en )
          if( scl )
            scl_cnt <= SCL_LOW;
          else
            scl_cnt <= SCL_HIGH;
        else
          scl_cnt <= scl_cnt - 1'b1;
      end

    SEND_START_S:
      begin
        if( scl_reload_en && ~scl )
          scl_cnt <= SCL_HIGH;
        else
          scl_cnt <= scl_cnt - 1'b1;
      end

    SEND_STOP_S:
      begin
        if( scl_reload_en && ~scl )
          scl_cnt <= SCL_HIGH;
        else
          scl_cnt <= scl_cnt - 1'b1;
      end

    CHECK_ACK_S:
      begin
        if( scl_reload_en && ~scl )
          scl_cnt <= SCL_HIGH;
        else
          scl_cnt <= scl_cnt - 1'b1;
      end

    RCV_BYTE_S:
      begin
        if( scl_reload_en )
          if( scl )
            scl_cnt <= SCL_LOW;
          else
            scl_cnt <= SCL_HIGH;
        else
          scl_cnt <= scl_cnt - 1'b1;
      end

    SEND_ACK_S:
      begin
        if( scl_reload_en && ~scl )
          scl_cnt <= SCL_HIGH;
        else
          scl_cnt <= scl_cnt - 1'b1;
      end

  endcase

assign scl_reload_en  = ( scl_cnt == 2 );

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    scl <= 1'b1;
  else
    if( scl_reload_en )
      if( state != SEND_STOP_S || ~scl )
        scl <= ~scl;

assign sda_read   = ( scl   ) ? ( scl_cnt == SCL_HIGH/2 ) : ( 1'b0 );
assign sda_write  = ( ~scl  ) ? ( scl_cnt == SCL_LOW/2  ) : ( 1'b0 );

//********************************************
// General control logic
//********************************************

//TODO: Clock stretching support add
assign scl_drive_en = 1'b1;

always_ff @( posedge clk_i )
  send_flag <= scl && ( scl_cnt == 2 );

assign ready_o = state == IDLE_S;

endmodule : i2c_transaction_ctrl

