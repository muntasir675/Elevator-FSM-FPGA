import elevator_pkg::*;

module request_resolver (
    input  logic        clk,
    input  logic        reset,
    // Button inputs
    input  logic [9:0]  E_buttons,
    input  logic [8:0]  up_buttons,
    input  logic [8:0]  down_buttons,
    // Controller inputs
    input  state        current_state,
    input  floor        current_floor,
    // Output request
    output floor        request
);  

// 1 for up, 0 for down
bit direction;
logic [9:0] pending_requests;

// Update pending requests based on button inputs
task automatic update_requests();
    for (integer i = 0; i < 10; i++) begin
        if (E_buttons[i])            pending_requests[i] <= 1;
        if (i < 9 && up_buttons[i])  pending_requests[i] <= 1;
        if (i > 0 && down_buttons[i-1]) pending_requests[i] <= 1;
    end
endtask

// Check current floor first then search in the given direction then opposite
// return 10 if none found, 10 is NONE in floor enum
function integer closest_request(input floor current_floor, input bit direction);
    integer i;
    if (direction) begin
        for (i = current_floor; i < 10; i++)
            if (pending_requests[i]) return i;
        for (i = current_floor-1; i >= 0; i--)
            if (pending_requests[i]) return i;
    end else begin
        for (i = current_floor; i >= 0; i--)
            if (pending_requests[i]) return i;
        for (i = current_floor+1; i < 10; i++)
            if (pending_requests[i]) return i;
    end
    return 10;
endfunction

always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
        pending_requests <= '0;
        direction <= 1;
        request <= NONE;
    end else begin
        update_requests();
        case(current_state)                                          // Determine direction based on current state
            UP:   direction <= 1;
            DOWN: direction <= 0;
            IDLE: direction <= 1;                                    // Default to up when idle
            OPEN: pending_requests[current_floor] <= 0;              // Clear request at current floor and use previous direction
        endcase
        request <= floor'(closest_request(current_floor, direction));// Find closest request in the determined direction
    end
end

endmodule