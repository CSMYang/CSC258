onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -label {Position Input} /dataPath/positionIn
add wave -noupdate -label {Color Input} /dataPath/colorIn
add wave -noupdate -label Reset /dataPath/resetn
add wave -noupdate -label {50 Hz Clock} /dataPath/CLOCK_50
add wave -noupdate -label {load X Enable} /dataPath/ld_x
add wave -noupdate -label {load Y Enable} /dataPath/ld_y
add wave -noupdate -label Color /dataPath/colour
add wave -noupdate -label {X Position} /dataPath/x
add wave -noupdate -label {Y Position} /dataPath/y
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {17246 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {252 ns}
