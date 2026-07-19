# Elevator-FSM-FPGA

10-floor elevator FSM controller written in SystemVerilog for FPGA implementation.

- 4 states: IDLE, UP, DOWN, OPEN
- 3 modules: controller (core FSM), request_resolver (pending-request tracking + closest-floor logic), elevator_ctrl (top wrapper)
- ssd.sv — 7-seg decoder for physical floor display on FPGA (not used in simulation)
- Comprehensive testbench with 9 test cases
