vlib work
vlog FIFO.svp fifo_interface.sv  fifo_tb.sv fifo_top.sv +cover -covercells
vsim -voptargs=+acc work.fifo_top -cover
add wave *
coverage save fifo_top.ucdb -onexit
run -all