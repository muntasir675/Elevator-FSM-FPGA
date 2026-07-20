# Elevator-FSM-FPGA

10-floor elevator controller written in SystemVerilog for FPGA.

Made to simulate button presses that were later tested on the FPGA with real inputs.

## Files

- elevator_pkg.sv — floor count and state definitions
- RTL/controller.sv — FSM (IDLE, UP, DOWN, OPEN)
- RTL/request_resolver.sv — tracks pending floors
- RTL/elevator_ctrl.sv — top wrapper
- RTL/ssd.sv — 7-seg decoder
- Testbench/elevator_ctrl_tb.sv — 9 test cases

## How to simulate

In ModelSim/Questa, run:

vsim -do run.do
