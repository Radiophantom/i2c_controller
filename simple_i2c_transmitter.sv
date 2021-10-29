module simple_i2c_fsm #(
  parameter 
)(
  input   rst_i,
  input   clk_i,

  // CSR interface
  i2c_if  i2c_if,
);

enum logic [2:0] {
  IDLE_S,
  START_S,
  EV5_S,
  ADDR_S,
  EV6_S,
  EV6_1_S,
  EV7_S,
  EV7_1_S,
  EV8_1_S,
  DATA_S,
  EV8_S,
  EV8_2_S,
  LAST_S,
  STOP_S
} state, next_state;

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
          if( start_bit_set )
            next_state = START_SEND_S;
        end

      START_SEND_S:
        begin
          if( ready && cmd_valid )
            next_state = SEND_ADDR_S;
        end

      SEND_ADDR_S:
        begin
          if( cmd_valid && ready )
            if( operation_type == READ )
              next_state = RCV_BYTE_S;
            else
              next_state = SEND_BYTE_S;
        end

      RCV_BYTE_S:
        begin
          if( ack_received_o && last_byte )
            next_state = STOP_SEND_S;
        end

      SEND_BYTE_S:
        begin
          if( cmd_valid && ready )
            next_state = STOP_SEND_S;
        end

      STOP_SEND_S:
        begin
          if( cmd_valid && ready )
            next_state = IDLE_S;
        end

      default:
        begin
          next_state = IDLE_S;
        end
    endcase
  end

endmodule

