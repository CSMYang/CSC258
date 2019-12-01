vlib work

vlog -timescale 1ns/1ns part2.v

vsim part2

log {/*}
add wave {/*}
force {CLOCK_50} 0 0,1 5 -r 10
force {SW[0]} 0
force {SW[1]} 0
force {SW[2]} 0
force {SW[3]} 1
force {SW[4]} 1
force {SW[5]} 1
force {SW[6]} 1
force {SW[7]} 1
force {SW[8]} 1
force {SW[9]} 1
force {KEY[0]} 1
force {KEY[3]} 0 0, 1 40
force {KEY[1]} 0 0, 1 80
run 200ns
