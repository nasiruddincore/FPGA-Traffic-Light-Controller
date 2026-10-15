# FPGA-Based Traffic Light Controller 🚦

An industry-oriented digital design project implementing a fully parameterizable traffic light controller using a Finite State Machine (FSM) in SystemVerilog. 

## Overview
This project models a 4-way intersection handling standard vehicle traffic, pedestrian walk requests, emergency vehicle preemption (all-red), and night (blinking) mode. The design uses a single-clock domain architecture by employing a clock-enable tick generator, making it highly reliable and synthesizable for FPGAs.

## Key Features & VLSI Concepts
*   **Strict Moore/Mealy FSM Design:** Ensures predictable, traceable state transitions.
*   **Safety Interlocks:** Hardware-level assertions guarantee conflicting green lights can never occur.
*   **Clock Division (Tick Generator):** Steps down a 50MHz/100MHz clock to a 10Hz enable signal, saving power and eliminating complex Clock Domain Crossing (CDC) issues.
*   **Priority Interrupts:** Synchronous preemption for emergency vehicles.

## Tools Used
*   **HDL:** SystemVerilog
*   **Simulation:** Icarus Verilog / EDA Playground / Vivado Simulator
*   **Synthesis:** Xilinx Vivado (Targeting Xilinx Artix-7 / Nexys A7)

## Folder Structure
* `/rtl` - Synthesizable SystemVerilog source code
* `/tb` - Self-checking testbench
* `/constraints` - Vivado XDC pin mappings
* `/waveforms` - VCD output screenshots

## How to Simulate
1. Open [EDA Playground](https://www.edaplayground.com/).
2. Upload `/rtl` files to the Design window and `/tb` files to the Testbench window.
3. Select Icarus Verilog and check "Open EPWave".
4. Run to visualize state transitions.

## Future Improvements
* Add vehicle loop sensors for adaptive green time.
* Add AXI-lite wrapper to allow control via an embedded soft-core processor (MicroBlaze).