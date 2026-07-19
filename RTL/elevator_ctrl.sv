import elevator_pkg::*;


module elevator_ctrl (
    input  logic        clk,
    input  logic        reset,
    // Button inputs
    input  logic [9:0]  E_buttons,
    input  logic [8:0]  up_buttons,
    input  logic [8:0]  down_buttons,
    // Outputs
    output floor        current_floor,
    output state        current_state
);

// Next requested floor from resolver to controller
floor request; 

// Instantiate request_resolver
request_resolver resolver (
    .clk(clk),                         
    .reset(reset), 
    // Inputs from buttons
    .E_buttons(E_buttons),
    .up_buttons(up_buttons),
    .down_buttons(down_buttons),
    // Inputs from controller
    .current_floor(current_floor),
    .current_state(current_state),
    // Output to controller
    .request(request)
);

// Instantiate controller
controller ctrl (
    .clk(clk),                         
    .reset(reset),
    // Input from resolver      
    .request(request),
    // Outputs to resolver
    .current_floor(current_floor),
    .current_state(current_state)
);

endmodule