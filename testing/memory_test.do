vlib work

vlog holyshit.v, SequenceMemory.v, MemoryAccessScheme.v, GenerateLevel.v, Timer.v, RateDivider.v, LFSR.v, GetOneHot.v


vsim -L altera_mf_ver holyshit

log {/*}
add wave {/*}

# ------- Create Clock
force {clock} 0 0ns, 1 {5ns} -r 10ns

# Reset
force {reset} 1'b1
force {start} 1'b0
force {user} 2'd1
force {address2} 5'd0
force {wren2} 1'b0
run 10ns

force {reset} 1'b0
force {start} 1'b0
force {user} 2'd1
force {address2} 5'd0
force {wren2} 1'b0
run 10ns

# start
# Reset
force {reset} 1'b0
force {start} 1'b1
force {user} 2'd1
force {address2} 5'd0
force {wren2} 1'b0
run 10ns

force {reset} 1'b0
force {start} 1'b0
force {user} 2'd1
force {address2} 5'd0
force {wren2} 1'b0
run 100ns

#Read from memory
force {reset} 1'b0
force {start} 1'b0
force {user} 2'd2
force {address2} 5'd0
force {wren2} 1'b0
run 20ns

force {reset} 1'b0
force {start} 1'b0
force {user} 2'd2
force {address2} 5'd1
force {wren2} 1'b0
run 20ns

force {reset} 1'b0
force {start} 1'b0
force {user} 2'd2
force {address2} 5'd2
force {wren2} 1'b0
run 20ns