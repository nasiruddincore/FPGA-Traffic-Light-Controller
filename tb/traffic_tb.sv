`timescale 1ns / 1ps

module traffic_tb;
    logic clk;
    logic rst_btn;
    logic ped_btn;
    logic emergency;
    logic night_mode;
    
    logic ns_g, ns_y, ns_r;
    logic ew_g, ew_y, ew_r;
    logic ped_walk, ped_dont;

    // File descriptor for CSV export
    int fd;

    top #(.CLK_HZ(100)) DUT (
        .*
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk; 
    end

    // Safety Assertion
    always @(posedge clk) begin
        if (ns_g && ew_g) begin
            $display("FATAL ERROR: BOTH DIRECTIONS GREEN!");
            $stop;
        end
    end

    // Data Logging to CSV for Streamlit
    always #100 begin // Sample every 100ns
        $fdisplay(fd, "%0d,%b,%b,%b,%b,%b,%b,%b,%b,%b", 
                  $time, ns_g, ns_y, ns_r, ew_g, ew_y, ew_r, ped_walk, emergency, night_mode);
    end

    // Stimulus
    initial begin
        $dumpfile("traffic.vcd");
        $dumpvars(0, traffic_tb);
        
        // Open CSV file and write header
        fd = $fopen("traffic_data.csv", "w");
        $fdisplay(fd, "Time,NS_G,NS_Y,NS_R,EW_G,EW_Y,EW_R,PED_WALK,EMERGENCY,NIGHT_MODE");
        
        rst_btn = 1; ped_btn = 0; emergency = 0; night_mode = 0;
        #20 rst_btn = 0;

        #1500; ped_btn = 1; #10; ped_btn = 0;
        #3000;
        
        emergency = 1; #500; emergency = 0;
        
        #1000; night_mode = 1; #1500; night_mode = 0;

        #2000;
        $fclose(fd); // Close CSV before finishing
        $finish;
    end
endmodule