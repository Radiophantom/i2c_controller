onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /i2c_bit_ctrl_tb/dut/rst_i
add wave -noupdate /i2c_bit_ctrl_tb/dut/clk_i
add wave -noupdate -divider {Input signals}
add wave -noupdate /i2c_bit_ctrl_tb/dut/cmd_valid_i
add wave -noupdate /i2c_bit_ctrl_tb/dut/start_send_i
add wave -noupdate /i2c_bit_ctrl_tb/dut/stop_send_i
add wave -noupdate /i2c_bit_ctrl_tb/dut/byte_send_i
add wave -noupdate /i2c_bit_ctrl_tb/dut/byte_i
add wave -noupdate /i2c_bit_ctrl_tb/dut/byte_rcv_i
add wave -noupdate /i2c_bit_ctrl_tb/dut/ack_en_i
add wave -noupdate -divider {Output signals}
add wave -noupdate /i2c_bit_ctrl_tb/dut/ready_o
add wave -noupdate /i2c_bit_ctrl_tb/dut/byte_o
add wave -noupdate /i2c_bit_ctrl_tb/dut/ack_received_o
add wave -noupdate -divider {Inout signals}
add wave -noupdate /i2c_bit_ctrl_tb/dut/scl_io
add wave -noupdate /i2c_bit_ctrl_tb/dut/sda_io
add wave -noupdate -divider {State machine}
add wave -noupdate /i2c_bit_ctrl_tb/dut/next_state
add wave -noupdate /i2c_bit_ctrl_tb/dut/state
add wave -noupdate -divider {SCL logic}
add wave -noupdate /i2c_bit_ctrl_tb/dut/scl_drive_en
add wave -noupdate /i2c_bit_ctrl_tb/dut/scl_reload_en
add wave -noupdate -radix unsigned /i2c_bit_ctrl_tb/dut/scl_cnt
add wave -noupdate /i2c_bit_ctrl_tb/dut/scl
add wave -noupdate -divider {SDA logic}
add wave -noupdate /i2c_bit_ctrl_tb/dut/sda_drive_en
add wave -noupdate /i2c_bit_ctrl_tb/dut/sda_write
add wave -noupdate /i2c_bit_ctrl_tb/dut/sda
add wave -noupdate /i2c_bit_ctrl_tb/dut/sda_shift_en
add wave -noupdate -radix binary /i2c_bit_ctrl_tb/dut/trans_byte_shift_reg
add wave -noupdate -divider {Receive logic}
add wave -noupdate /i2c_bit_ctrl_tb/dut/sda_read
add wave -noupdate /i2c_bit_ctrl_tb/dut/sda_in
add wave -noupdate -divider {Internal logic}
add wave -noupdate -radix unsigned /i2c_bit_ctrl_tb/dut/byte_rcv_cnt
add wave -noupdate -radix unsigned /i2c_bit_ctrl_tb/dut/byte_sent_cnt
add wave -noupdate /i2c_bit_ctrl_tb/dut/send_flag
add wave -noupdate /i2c_bit_ctrl_tb/dut/ack_en_flag
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {176566325 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {440711250 ps}
