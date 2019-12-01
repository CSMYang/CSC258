vlib work

vlog -timescale 1ns/1ns morseCode.v

vsim MorseCode

log {/*}
add wave {/*}
force {CLOCK_50} 0 0 ns, 1 1 ns -r 2
force {KEY[0]} 0 0 ns, 1 4 ns
force {KEY[1]} 0 0 ns, 1 8 ns
force {SW[2:0]} 010 0 ns
run 80 ns
