catch { vdel -lib work -all -force }

if {![file exists work]} { 
    vlib work 
}
vmap work work

puts "========================================="
puts "ELEVATOR CONTROLLER TESTBENCH"
puts "========================================="
puts ""

# Compile package first
vlog -sv elevator_pkg.sv

# Compile design modules
vlog -sv RTL/elevator_ctrl.sv
vlog -sv RTL/controller.sv
vlog -sv RTL/request_resolver.sv

# Compile testbench
vlog -sv Testbench/elevator_ctrl_tb.sv

# Simulate
vsim -voptargs=+acc elevator_ctrl_tb

# Add signals to waveform
add wave sim:/elevator_ctrl_tb/E_buttons
add wave sim:/elevator_ctrl_tb/up_buttons
add wave sim:/elevator_ctrl_tb/down_buttons
add wave sim:/elevator_ctrl_tb/current_floor
add wave sim:/elevator_ctrl_tb/current_state
add wave sim:/elevator_ctrl_tb/dut/ctrl/timer
add wave sim:/elevator_ctrl_tb/dut/ctrl/clock_enable
add wave sim:/elevator_ctrl_tb/dut/ctrl/request

add wave sim:/elevator_ctrl_tb/clk
add wave sim:/elevator_ctrl_tb/reset

# Run simulation
run -all

# View waveform
view wave
wave zoom full

puts "Comment out delay output in line 45 of testbench for output readability"