vlib work

vlog -sv i2c_bit_ctrl_tb.sv
vlog -sv i2c_transaction_ctrl.sv
vopt +acc -o top_i2c i2c_bit_ctrl_tb
vsim top_i2c

do wave.do

run -all
