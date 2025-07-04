vlib work
vlog top.v
vsim -voptargs=+acc work.top
add wave * top/mc/* top/mc/dataMemory/mem top/mc/dataMemory/*
run -all
#quit -sim