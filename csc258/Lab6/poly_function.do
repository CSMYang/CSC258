# Set the working dir, where all compiled Verilog goes.
vlib work

# Compile all Verilog modules in mux.v to working dir;
# could also have multiple Verilog files.
# The timescale argument defines default time unit
# (used when no unit is specified), while the second number
# defines precision (all times are rounded to this value)
vlog -timescale 1ns/1ns poly_function.v

# Load simulation using mux as the top level simulation module.
vsim fpga_top

# Log all signals and add some signals to waveform window.
log {/*}
# add wave {/*} would add all items in top level simulation module.
add wave {/*}
force {CLOCK_50} 1 0, 0 10 ns -r 10

force {KEY[0]} 0 0, 1 10
# A = 3, B = 4, C = 5, X = 6, RESULT = 207 (11001111)
force {SW[7: 0]} 00000011 10, 00000100 30, 00000101 50, 00000110 70
# A
force {KEY[1]} 0 10, 1 20
# B
force {KEY[1]} 0 30, 1 40
# C
force {KEY[1]} 0 50, 1 60
# X
force {KEY[1]} 0 70, 1 80
# run
force {KEY[1]} 0 90, 1 100

#force {KEY[1]} 0 100, 1 110
# A = B = C = X = 1, out = 3
#force {SW[7: 0]} 00000001 0
run 200ns
