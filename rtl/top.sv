`timescale 1ns / 1ps

module top #(
    parameter CLK_HZ = 50_000_000 // 50 MHz default
)(
    input  logic clk,
    input  logic rst_btn,       // Assuming active-high button
    input  logic ped_btn,
    input  logic emergency,
    input  logic night_mode,
    
    output logic ns_g, ns_y, ns_r,
    output logic ew_g, ew_y, ew_r,
    output logic ped_walk, ped_dont
);

    logic rst_n;
    assign rst_n = ~rst_btn;

    // Clock Enable Tick Generator (10 Hz)
    localparam DIV = CLK_HZ / 10;
    logic [$clog2(DIV)-1:0] cnt;
    logic tick;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= 0;
            tick <= 0;
        end else begin
            if (cnt == DIV - 1) begin
                cnt <= 0;
                tick <= 1;
            end else begin
                cnt <= cnt + 1;
                tick <= 0;
            end
        end
    end

    // Instantiate FSM
    traffic_fsm u_fsm (
        .clk(clk),
        .rst_n(rst_n),
        .tick(tick),
        .ped_btn(ped_btn),
        .emergency(emergency),
        .night_mode(night_mode),
        .ns_g(ns_g), .ns_y(ns_y), .ns_r(ns_r),
        .ew_g(ew_g), .ew_y(ew_y), .ew_r(ew_r),
        .ped_walk(ped_walk), .ped_dont(ped_dont)
    );

endmodule