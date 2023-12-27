vlib work

vlog Timer.v

vsim -g CLOCK_FREQUENCY=4 -g MAX_TIME=4 Timer

log {/*}
add wave {/*}

# ------- Create Clock
force {clock} 0 0ns, 1 {5ns} -r 10ns

force {start} 1'b0
force {speed} 2'b01
run 70ns

force {start} 1'b1
force {speed} 2'b01
run 70ns

force {start} 1'b0
force {speed} 2'b01
run 70ns


