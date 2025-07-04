vlib work
vlog *.v
vsim -voptargs=+acc work.top
add wave * top/mc/* top/mc/dataMemory/mem top/mc/registerFile/file 
run -all
#quit -sim