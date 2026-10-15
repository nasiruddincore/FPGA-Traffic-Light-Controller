`timescale 1ns / 1ps

module traffic_fsm #(
    parameter TICK_HZ = 10  // 10 ticks per second
)(
    input  logic clk,
    input  logic rst_n,
    input  logic tick,         // 10Hz clock enable
    input  logic ped_btn,
    input  logic emergency,
    input  logic night_mode,
    
    output logic ns_g, ns_y, ns_r,
    output logic ew_g, ew_y, ew_r,
    output logic ped_walk, ped_dont
);

    // Timing parameters (in ticks)
    localparam T_GREEN   = 12 * TICK_HZ;
    localparam T_YELLOW  = 3  * TICK_HZ;
    localparam T_ALLRED  = 1  * TICK_HZ;
    localparam T_WALK    = 8  * TICK_HZ;
    localparam T_BLINK   = 5; // 0.5 seconds at 10Hz

    // State definitions
    typedef enum logic [3:0] {
        S_NS_G, S_NS_Y, S_ALL_RED1, 
        S_EW_G, S_EW_Y, S_ALL_RED2, 
        S_PED_WALK, S_EMERGENCY, S_NIGHT
    } state_t;

    state_t state, next_state;
    logic [15:0] timer;
    logic timer_reset;
    logic ped_latched;
    logic blink_tog;

    // Timer logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            timer <= 0;
            blink_tog <= 0;
        end else if (tick) begin
            if (timer_reset) timer <= 0;
            else timer <= timer + 1;
            
            if (timer % T_BLINK == 0) blink_tog <= ~blink_tog;
        end
    end

    // Pedestrian request latch
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) ped_latched <= 0;
        else if (ped_btn) ped_latched <= 1;
        else if (state == S_PED_WALK) ped_latched <= 0;
    end

    // State Register
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) state <= S_ALL_RED1;
        else if (emergency) state <= S_EMERGENCY;
        else if (night_mode) state <= S_NIGHT;
        else if (tick) state <= next_state;
    end

    // Next State Logic
    always_comb begin
        next_state = state;
        timer_reset = 0;

        case (state)
            S_NS_G: begin
                if (timer >= T_GREEN) begin
                    next_state = S_NS_Y;
                    timer_reset = 1;
                end
            end
            S_NS_Y: begin
                if (timer >= T_YELLOW) begin
                    next_state = S_ALL_RED1;
                    timer_reset = 1;
                end
            end
            S_ALL_RED1: begin
                if (timer >= T_ALLRED) begin
                    // FIX: Replaced ternary operator with if-else
                    if (ped_latched) 
                        next_state = S_PED_WALK;
                    else 
                        next_state = S_EW_G;
                        
                    timer_reset = 1;
                end
            end
            S_EW_G: begin
                if (timer >= T_GREEN) begin
                    next_state = S_EW_Y;
                    timer_reset = 1;
                end
            end
            S_EW_Y: begin
                if (timer >= T_YELLOW) begin
                    next_state = S_ALL_RED2;
                    timer_reset = 1;
                end
            end
            S_ALL_RED2: begin
                if (timer >= T_ALLRED) begin
                    // FIX: Replaced ternary operator with if-else
                    if (ped_latched) 
                        next_state = S_PED_WALK;
                    else 
                        next_state = S_NS_G;
                        
                    timer_reset = 1;
                end
            end
            S_PED_WALK: begin
                if (timer >= T_WALK) begin
                    // Return to an all red clearance state safely
                    next_state = S_ALL_RED2; 
                    timer_reset = 1;
                end
            end
            S_EMERGENCY: begin
                if (!emergency) begin
                    next_state = S_ALL_RED1;
                    timer_reset = 1;
                end
            end
            S_NIGHT: begin
                if (!night_mode) begin
                    next_state = S_ALL_RED1;
                    timer_reset = 1;
                end
            end
            default: next_state = S_ALL_RED1;
        endcase
    end

    // Output Logic
    always_comb begin
        // Default safe outputs (All Red)
        ns_g=0; ns_y=0; ns_r=1;
        ew_g=0; ew_y=0; ew_r=1;
        ped_walk=0; ped_dont=1;

        case (state)
            S_NS_G:     begin ns_g=1; ns_r=0; end
            S_NS_Y:     begin ns_y=1; ns_r=0; end
            S_EW_G:     begin ew_g=1; ew_r=0; end
            S_EW_Y:     begin ew_y=1; ew_r=0; end
            S_PED_WALK: begin ped_walk=1; ped_dont=0; end
            S_NIGHT:    begin 
                ns_r=0; ns_y = blink_tog; 
                ew_r=blink_tog; 
            end
            S_EMERGENCY, S_ALL_RED1, S_ALL_RED2: begin /* Defaults hold */ end
        endcase
    end
endmodule