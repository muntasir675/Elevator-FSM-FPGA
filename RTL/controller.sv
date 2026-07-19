import elevator_pkg::*;

module controller (
    input  logic        clk,
    input  logic        reset,
    input  floor        request,
    
    output floor        current_floor,
    output state        current_state
);

logic [1:0]  timer;
logic        clock_enable;
logic [25:0] counter;

// Block 1: Clock Enable pulses once per second
always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
        counter <= 0;
        clock_enable <= 0;
    end else begin
        if (counter == COUNTER_MAX) begin
            counter <= 0;
            clock_enable <= 1;  // Pulse for 1 cycle
        end else begin
            counter <= counter + 1;
            clock_enable <= 0;
        end
    end
end

// Block 2: add 1 to timer every second reset every 2 seconds
always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
        timer <= 0;
    end else begin
        if (timer == 2)
            timer <= 0;
        else if (clock_enable && timer<2)
            timer <= timer + 1;
    end
end


task automatic get_next_state();
    // Stay OPEN for 2 seconds
    if(current_state == OPEN && timer < 2)
        current_state <= OPEN;
    // There is a request
    else if (request != NONE) begin
        if (request > current_floor)
            current_state <= UP;
        else if (request < current_floor)
            current_state <= DOWN;
        else
            current_state <= OPEN;  // Same floor request
    end
    // No requests
    else
        current_state <= IDLE;
endtask

task automatic change_floor(input bit direction);
    floor next_floor;
    // designate the next floor based on direction 1 = UP 0 = DOWN
    next_floor = direction ? current_floor.next() : current_floor.prev();
    current_floor <= next_floor;
    // OPEN when at requested floor
    if (next_floor == request) begin
        current_state <= OPEN;
    end
endtask


// Block 3: FSM
// Execute state actions every 2 seconds based on current state
// UP and DOWN change floor until OPEN
// IDLE and OPEN check for next state based on requests or previous open
always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
        current_floor <= FLOOR_0;
        current_state <= IDLE;
    end else if(timer == 2) begin
        case (current_state)
            IDLE: get_next_state();
            OPEN: get_next_state();
            UP:   change_floor(1);
            DOWN: change_floor(0);
        endcase
    end
end


endmodule