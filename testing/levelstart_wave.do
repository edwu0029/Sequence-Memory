vlib work

vlog LevelStartAnim.v

vsim -g CLOCK_FREQUENCY=4 -g MAX_TIME=4 LevelStartAnim

log {/*}
add wave {/*}

# ------- Create Clock
force {clock} 0 0ns, 1 {5ns} -r 10ns

force {reset} 1'b0
force {start} 1'b0
run 10ns

force {reset} 1'b0
force {start} 1'b0
run 10ns

force {reset} 1'b0
force {start} 1'b1
run 10ns

force {reset} 1'b0
force {start} 1'b0
run 1400ns


