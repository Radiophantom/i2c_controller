vlib work

vlog -sv -f files
vopt +acc -o top_i2c i2c_bit_ctrl_tb
vsim top_i2c

do wave.do

run -all
