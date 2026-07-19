`timescale 1ns/1ps
import elevator_pkg::*;

// NOTES: 
// 1. Comment out delay output in line 45 for output readability
// 2. Down button[0] is for floor 1 while Up button[0] and E button[0] is for floor 0
// 3. The counter max value was lowered from 49_999_999 to 4999 for faster simulation inside file elevator_pkg.sv
// 4. The elevator will wait for the timer to reach 2 to start executing when idle

module elevator_ctrl_tb;

logic clk, reset;
logic [9:0] E_buttons;
logic [8:0] up_buttons, down_buttons;
floor current_floor;
state current_state;

// Instantiate the elevator controller
elevator_ctrl dut (
    .clk(clk),
    .reset(reset),
    .E_buttons(E_buttons),
    .up_buttons(up_buttons),
    .down_buttons(down_buttons),
    .current_floor(current_floor),
    .current_state(current_state)
);

// Initial conditions
floor prev_floor = FLOOR_0;
state prev_state = IDLE;
time prev_time = 0;
initial clk = 0;

always #10 clk = ~clk;

// Monitor current floor and state
initial $monitor("Current: %s | %s", current_floor.name(), current_state.name());


always @(current_floor or current_state) begin
    // Track duration for previous floor/state combo
    if ((current_floor != prev_floor) || (current_state != prev_state)) begin
        // Comment out for clearer output
        $display("Duration %0dns at %s doing %s",$time - prev_time, prev_floor.name(), prev_state.name());
        // Update previous tracking
        prev_floor = current_floor;
        prev_state = current_state;
        prev_time = $time;
    end
end

// Reset system
task reset_system();
    $display("\n===== RESET =====");
    reset = 1; E_buttons = 0; up_buttons = 0; down_buttons = 0;
    prev_time = $time;
    repeat(5) @(posedge clk);
    reset = 0; @(posedge clk);
endtask

// Press a sequence of internal buttons with optional delay between presses
task automatic press_sequence(input int floors[$], input int delay_us=0);
    foreach (floors[f]) begin
        E_buttons[floors[f]] = 1; @(posedge clk); E_buttons[floors[f]] = 0;
        $display("Internal button %0d pressed (Currently at %s)", floors[f], current_floor.name());
        #(delay_us);
    end
endtask

// Press up or down button
task press_up(input int floor_num);
    up_buttons[floor_num] = 1; @(posedge clk); up_buttons[floor_num] = 0;
    $display("UP button %0d pressed (Currently at %s)", floor_num, current_floor.name());
endtask

task press_down(input int floor_num);
    down_buttons[floor_num] = 1; @(posedge clk); down_buttons[floor_num] = 0;
    $display("DOWN button %0d (floor %0d) pressed (Currently at %s)", floor_num,  floor_num+1, current_floor.name());
endtask

// Throw error if elevator is OPEN and (UP or DOWN) at the same time
assert property (@(posedge clk) disable iff (reset)
    !((current_state == OPEN) && ((current_state == UP) || (current_state == DOWN)) )
);


initial begin
    // To wait for 1 sim second we wait 100,000 nanoseconds #100000
    //#3000000; Wait for 30 seconds
    reset_system();
    
    $display("\n===== TEST 1: Floor Movement Timing and Door Open Duration =====");
    press_down(FLOOR_3); 
    #3000000;

    // will be at floor 4 now
    $display("\n===== TEST 2: Smaller distance prioritization =====");
    press_sequence('{6, 5}, 400); 
    #3000000;

    // will be at floor 6 now
    $display("\n===== TEST 3: Multiple UP Requests vs Closer DOWN Request =====");
    press_sequence('{8,7,9,3}, 5000); 
    #3000000;

    // will be at floor 3 now
    // IDLE will default to up direction 
    $display("\n===== TEST 4: Boundary Conditions and Default directon =====");
    press_sequence('{0,9}, 5000); 
    #4000000;

    // will be at floor 0 now
    $display("\n===== TEST 5: Same Floor Request (Immediate Door Open) =====");
    press_sequence('{9}, 200);
    wait(current_floor == FLOOR_9); 
    #300000;
    // repeat
    press_sequence('{9}, 200);
    wait(current_floor == FLOOR_9); 
    #300000;

    // will be at floor 9 now
    $display("\n===== TEST 6: Complete Current Direction First =====");
    // wait 1 clock cycle between presses
    // It should start moving down to 3 stop at 6 then 3 then 1 then 8 because 8 will be pushed after it starts moving past it
    press_sequence('{3, 6, 8, 1}, 200000); 
    #3000000; // Wait for 30 seconds


    press_sequence('{9}); // initialize for repeating same test with 7 instead of 8
    #4000000; 

    // will be at floor 9 now
    $display("\n===== TEST 6(again): Complete Current Direction First =====");
    // wait 1 clock cycle between presses
    // Now it should start moving down to 3 stop at 7 then 6 then 3 then 1 because 7 will be pushed before it starts moving past it
    press_sequence('{3, 6, 7, 1}, 200000);
    #3000000;

    // will be at floor 1 now
    $display("\n===== TEST 7: Multiple Simultaneous Internal and External Requests =====");
    $display("Pressing internal requests for floors 2 and 4, up request at 6 and down request at 8 simultaneously");
    E_buttons[2] = 1; E_buttons[4] = 1; up_buttons[6] = 1; down_buttons[7] = 1;
    #1000; // Simultaneous requests at floors 2,4,6,8
    E_buttons[2] = 0; E_buttons[4] = 0; up_buttons[6] = 0; down_buttons[7] = 0;
    #3000000;

    // will be at floor 8 now
    $display("\n===== TEST 8: The Same Request Simultaneously Internal and External =====");
    $display("Pressing up, down and internal requests for floor 2 simultaneously");
    E_buttons[2] = 1; up_buttons[2]= 1; down_buttons[1] = 1;
    #1000; // 3 Simultaneous requests at floor 2
    E_buttons[2] = 0; E_buttons[4] = 0; up_buttons[6] = 0; down_buttons[7] = 0;
    #3000000;

    // will be at floor 8 now
    $display("\n===== TEST 9: Error Handling (Out of Range) =====");
    press_sequence('{100}); press_down(100); press_up(-5); // Nothing will happen ignored by system
    #3000000;

    $display("\n===== DONE =====\n");
    $stop;

end

endmodule