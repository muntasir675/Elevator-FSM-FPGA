# Elevator FSM FPGA

10-floor elevator controller written in SystemVerilog, implementing a SCAN scheduling algorithm with full request arbitration.

## Requirements
- **QuestaSim / ModelSim** (Intel FPGA Edition or standard) for simulation
- **Intel Quartus Prime** (Lite Edition 20.1+ or 24.1+) for FPGA synthesis

## Structure
- `elevator_pkg.sv` — Shared type definitions (floor/state enums, timing parameter)
- `RTL/controller.sv` — Core FSM (IDLE, UP, DOWN, OPEN) with clock-enable generator and door timer
- `RTL/request_resolver.sv` — Request scanner implementing SCAN scheduling algorithm
- `RTL/elevator_ctrl.sv` — Top-level wrapper connecting controller and request resolver
- `RTL/ssd.sv` — Seven-segment display decoder
- `Testbench/elevator_ctrl_tb.sv` — 9 test scenarios with SVA assertion
- `run.do` — ModelSim/Questa simulation script

## Architecture
```
elevator_ctrl (top)
├── request_resolver    Scans pending requests, outputs next destination
│   ↑↓                 Feeds back current_floor and current_state
└── controller          FSM + timing, outputs floor and state
```

## Running Simulation
```tcl
do run.do
```
Compiles the package, RTL modules, and testbench, then runs the full simulation with waveform signals pre-loaded.

## Verification & Testing
9 test scenarios covering timing, priority, boundary conditions, and error handling:

| Test | Scenario | What It Verifies |
|---|---|---|
| **RESET** | System reset | Clean startup at FLOOR_0/IDLE |
| **TEST 1** | Floor movement timing | Correct 2s travel per floor, 2s door open duration |
| **TEST 2** | Smaller distance priority | Closer request serviced first in same direction |
| **TEST 3** | UP vs DOWN priority | Completes all UP requests before reversing to DOWN |
| **TEST 4** | Boundary conditions | IDLE defaults to UP, full travel across all floors |
| **TEST 5** | Same-floor request | Immediate door open without movement |
| **TEST 6** | Mid-trip request queuing | Requests arriving during travel are correctly queued |
| **TEST 7** | Simultaneous internal + external | Mixed button presses serviced in correct order |
| **TEST 8** | Duplicate requests | Same floor pressed via multiple buttons handled once |
| **TEST 9** | Out-of-range inputs | Invalid floor numbers safely ignored |

```
# From transcript — all 9 tests pass, 0 errors
# Total simulation time: 36,202,370 ns
```

## FPGA Implementation
- Tested on Intel FPGA with 50 MHz onboard clock
- The RTL defines 9 external up buttons, 9 external down buttons, and 10 internal buttons — on the FPGA these were combined for practicality
- `ssd.sv` drives a 7-segment display showing the current floor number
- `COUNTER_MAX` adjusted to `49_999_999` for real 1-second timing intervals

## Notes
- **SCAN Scheduling**: Services all requests in the current direction before reversing — the standard elevator algorithm. Direction is inherited from the previous state; IDLE defaults to upward scan.
- **Simulation Timing**: `COUNTER_MAX` is set to 4999 for fast simulation. For real hardware, change to `49_999_999` in `elevator_pkg.sv` for 1-second intervals.
- **Door Timer**: The FSM advances only when `timer == 2` (every 2 simulated seconds). Floor-to-floor travel and door open duration each take 2 seconds.
- **Button Indexing**: `down_buttons[0]` corresponds to floor 1 (floor 0 has no down button in a real building).
