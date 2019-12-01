vlib work

vlog Lab7Part1.v ram32x4.v
vsim -L altera_mf_ver exc 



log {/*}
add wave {/*}



force {SW[8]} 0
force {SW[7]} 0
force {SW[6]} 0
force {SW[5]} 0
force {SW[4]} 0
force {SW[3]} 0
force {SW[2]} 0
force {SW[1]} 0
force {SW[0]} 0

force {KEY[0]} 1
force {SW[9]} 0

run 10ns

#write 5 into address 00000

#data
force {SW[3]} 0
force {SW[2]} 1
force {SW[1]} 0
force {SW[0]} 1

#address
force {SW[8]} 0
force {SW[7]} 0
force {SW[6]} 0
force {SW[5]} 0
force {SW[4]} 0

#write enable
force {SW[9]} 1

#clock edge
force {KEY[0]} 0
run 10ns
force {KEY[0]} 1
run 10ns

-------------------------------------------------------------


# write 10 into address 00101

#data
force {SW[3]} 1
force {SW[2]} 0
force {SW[1]} 1
force {SW[0]} 0

#address
force {SW[8]} 0
force {SW[7]} 0
force {SW[6]} 1
force {SW[5]} 0
force {SW[4]} 1

#write enable
force {SW[9]} 1

#clock edge
force {KEY[0]} 0
run 10ns
force {KEY[0]} 1
run 10ns


-----------------------------------------------------------


# write 15 into address 00001

#data
force {SW[3]} 1
force {SW[2]} 1
force {SW[1]} 1
force {SW[0]} 1

#address
force {SW[8]} 0
force {SW[7]} 0
force {SW[6]} 0
force {SW[5]} 0
force {SW[4]} 1

#write enable
force {SW[9]} 1

#clock edge
force {KEY[0]} 0
run 10ns
force {KEY[0]} 1
run 10ns


--------------------------------------------------------------

# read address 00001


#address
force {SW[8]} 0
force {SW[7]} 0
force {SW[6]} 0
force {SW[5]} 0
force {SW[4]} 1

#write enable
force {SW[9]} 0

#clock edge
force {KEY[0]} 0
run 10ns
force {KEY[0]} 1
run 10ns


---------------------------------------------------------------


# read address 00000


#address
force {SW[8]} 0
force {SW[7]} 0
force {SW[6]} 0
force {SW[5]} 0
force {SW[4]} 0

#write enable
force {SW[9]} 0

#clock edge
force {KEY[0]} 0
run 10ns
force {KEY[0]} 1
run 10ns


---------------------------------------------------------------


# read address 00101


#address
force {SW[8]} 0
force {SW[7]} 0
force {SW[6]} 1
force {SW[5]} 0
force {SW[4]} 1

#write enable
force {SW[9]} 0

#clock edge
force {KEY[0]} 0
run 10ns
force {KEY[0]} 1
run 10ns