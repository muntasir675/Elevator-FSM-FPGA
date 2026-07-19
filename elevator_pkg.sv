package elevator_pkg;

// Timing parameter for simulation/synthesis should be correct value when on FPGA
// parameter COUNTER_MAX = 26'd49_999_999;  // ~2 seconds at 50MHz (actual value)
parameter COUNTER_MAX = 26'd4999;           // temporary value for faster simulation

typedef enum logic [3:0] {
    FLOOR_0 = 0,
    FLOOR_1 = 1,
    FLOOR_2 = 2,
    FLOOR_3 = 3,
    FLOOR_4 = 4,
    FLOOR_5 = 5,
    FLOOR_6 = 6,
    FLOOR_7 = 7,
    FLOOR_8 = 8,
    FLOOR_9 = 9,
    NONE    = 10
} floor;

typedef enum bit [1:0] {
    UP = 0,
    DOWN = 1,
    IDLE = 2,
    OPEN = 3
} state;

endpackage