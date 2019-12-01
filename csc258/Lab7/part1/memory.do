# Set the working dir, where all compiled Verilog goes.
vlib work

# Compile all verilog modules in mux.v to working dir;
# could also have multiple verilog files.
vlog -timescale 1ns/1ns ram32x4.v

# Load simulation using mux as the top level simulation module.
vsim -L altera_mf_ver ram32x4

# Log all signals and add some signals to waveform window.
log {/*}
# add wave {/*} would add all items in top level simulation module.
add wave {/*}

force {address[4: 0]} 00001 0, 00010 20, 00011 40 ,00100 60 ,00101 80
force {clock} 0 0 , 1 10 -r 10
force {data[3: 0]} 0001 0 ,0010 20 ,0011 40 ,0100 60 ,0101 80
force {wren} 0 0 , 1 20 , 0 60
run 90ps
