vlib work

vlog PulseAnim.v GenerateLevel.v MemoryAccessScheme.v ResultsMemory.v RateDivider.v Timer.v GetOneHot.v LFSR.v SequenceMemory.v LevelStartAnim.v GameLogic.v


vsim -L altera_mf_ver GameLogic

log {/*}
add wave {/*}

# ------- Create Clock
force {clock} 0 0ns, 1 {5ns} -r 10ns

# Reset
force {reset} 1'b1
force {start} 1'b0
run 10ns

force {reset} 1'b0
force {start} 1'b0
run 10ns

# Go through generate and level start
force {reset} 1'b0
force {start} 1'b1
run 10ns

force {reset} 1'b0
force {start} 1'b0
run 1200ns

# Get Input

force {reset} 1'b0
force {start} 1'b0
force {hasInput} 1'b1
force {inputOneHot} 4'b0010
run 200ns