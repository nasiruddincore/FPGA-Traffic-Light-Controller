🚦 FPGA-Based Traffic Light Controller

An industry-oriented digital design project implementing a fully parameterizable traffic light controller using a Finite State Machine (FSM) in SystemVerilog. It features a custom Python/Streamlit Verification Dashboard for automated hardware-in-the-loop co-simulation.

📖 Overview

This project models a 4-way intersection handling standard vehicle traffic, pedestrian walk requests, emergency vehicle preemption (all-red), and night (blinking) mode. The design uses a single-clock domain architecture by employing a clock-enable tick generator, making it highly reliable, avoiding Clock Domain Crossing (CDC) issues, and keeping it fully synthesizable for FPGAs like the Artix-7.

✨ Key Features & VLSI Concepts

Strict Moore/Mealy FSM Design: Ensures predictable, traceable state transitions.

Safety Interlocks: Hardware-level assertions in the testbench guarantee conflicting green lights can never occur.

Clock Division (Tick Generator): Steps down a 50MHz/100MHz clock to a 10Hz enable signal, saving power and maintaining a synchronous design.

Priority Interrupts: Synchronous preemption for emergency vehicles and debounced pedestrian requests.

Automated Co-Simulation: A modern web-based UI built in Python to compile, simulate, and visualize digital waveforms dynamically.

🗂️ Folder Structure

FPGA-Traffic-Light-Controller/
│
├── rtl/                # Synthesizable SystemVerilog source code (.v, .sv)
├── tb/                 # Self-checking testbench for simulation (.sv)
├── constraints/        # Physical pin mapping for FPGA (e.g., nexys_a7.xdc)
├── scripts/            # Automation scripts (PowerShell, Makefiles)
├── app.py              # Streamlit Web Dashboard for interactive verification
├── README.md           # Project documentation
├── .gitignore          # Ignores build artifacts (*.vcd, *.vvp, Vivado logs)
└── LICENSE             # MIT License


🛠️ Tools Required

To run the simulation and web dashboard locally, you need:

Icarus Verilog (Compiler) & GTKWave (Waveform Viewer)

Python 3.8+ (For the Dashboard)

Xilinx Vivado (Only required if programming a physical FPGA board)

Install Python Dependencies:

pip install streamlit pandas plotly


🚀 How to Run the Co-Simulation Dashboard

The easiest and most visually impressive way to run this project is through the custom Streamlit UI.

Open your terminal/PowerShell in the project root folder.

Run the Streamlit application:

streamlit run app.py


A local web server will launch in your browser.

Click "🚀 Run Simulation" in the sidebar. The Python backend will compile the SystemVerilog code, execute the testbench, log the hardware state, and render an interactive, neon-styled Logic Analyzer.

⏱️ FSM State Flow

The primary timing sequence (configurable via parameters) is:

S_NS_G: North-South Green (12s)

S_NS_Y: North-South Yellow (3s)

S_ALL_RED1: Clearance (1s)

S_EW_G: East-West Green (12s)

S_EW_Y: East-West Yellow (3s)

S_ALL_RED2: Clearance (1s)

Interrupts: S_PED_WALK (8s inserted after All-Red), S_EMERGENCY (Immediate All-Red), S_NIGHT (Flashing Yellow/Red).

🔌 FPGA Implementation

This design is fully synthesizable. A constraints file (nexys_a7.xdc) is included in the constraints/ folder targeting the Xilinx Nexys A7 (Artix-7).

Create a Vivado RTL project.

Add top.sv and traffic_fsm.sv as design sources.

Add the .xdc file as constraints.

Run Synthesis, Implementation, and generate the Bitstream to flash the board.

🤝 Future Improvements

Add vehicle loop sensors for density-based adaptive green timing.

Integrate an AXI-lite wrapper to allow control via an embedded soft-core processor (e.g., MicroBlaze/RISC-V).

Add formal verification proofs (SymbiYosys) to mathematically prove the absence of conflicting green states.

📄 License

This project is licensed under the MIT License - see the LICENSE file for details.
