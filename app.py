import streamlit as st
import pandas as pd
import subprocess
import os
import plotly.graph_objects as go

st.set_page_config(page_title="Traffic FSM Dashboard", layout="wide", page_icon="🚦")

# --- Custom CSS for a modern look ---
st.markdown("""
    <style>
    .stButton>button {
        width: 100%;
        border-radius: 5px;
        font-weight: bold;
    }
    .metric-container {
        background-color: #1E1E1E;
        padding: 15px;
        border-radius: 8px;
        border: 1px solid #333;
    }
    </style>
""", unsafe_allow_html=True)

st.title("🚦 SystemVerilog Co-Simulation Dashboard")
st.markdown("Hardware-in-the-Loop Verification UI. Compiles RTL, executes the testbench, and renders stacked digital waveforms.")

# --- Sidebar Controls ---
with st.sidebar:
    st.header("⚙️ Simulation Engine")
    st.markdown("Run the `iverilog` compiler and simulate.")
    
    if st.button("🚀 Run Simulation", type="primary"):
        with st.spinner("Compiling & Simulating..."):
            compile_cmd = ["iverilog", "-g2012", "-o", "traffic_sim.vvp", 
                           "rtl/traffic_fsm.sv", "rtl/top.sv", "tb/traffic_tb.sv"]
            comp_result = subprocess.run(compile_cmd, capture_output=True, text=True)
            
            if comp_result.returncode != 0:
                st.error("❌ Compilation Failed!")
                st.code(comp_result.stderr, language="bash")
            else:
                sim_result = subprocess.run(["vvp", "traffic_sim.vvp"], capture_output=True, text=True)
                st.success("✅ Simulation Complete!")
                with st.expander("Terminal Output"):
                    st.code(sim_result.stdout, language="bash")

# --- Main Dashboard Area ---
if os.path.exists("traffic_data.csv"):
    df = pd.read_csv("traffic_data.csv")
    
    # 1. Top Metrics Row
    col1, col2, col3, col4 = st.columns(4)
    col1.metric("Total Sim Time", f"{df['Time'].max()} ns")
    col2.metric("Clock Cycles Logged", f"{len(df)}")
    col3.metric("Pedestrian Events", f"{df['PED_WALK'].sum()}")
    col4.metric("Emergency Overrides", f"{df['EMERGENCY'].sum()}")

    st.divider()
    st.subheader("📊 Digital Logic Analyzer")

    # 2. Modern Plotly Graph Objects (Stacked Signals)
    fig = go.Figure()

    # Define signals and striking neon hex colors for the dark theme
    signals = ["NS_G", "NS_Y", "NS_R", "EW_G", "EW_Y", "EW_R", "PED_WALK", "EMERGENCY", "NIGHT_MODE"]
    colors = {
        "NS_G": "#00FF00", "NS_Y": "#FFFF00", "NS_R": "#FF0000",
        "EW_G": "#39FF14", "EW_Y": "#FFEA00", "EW_R": "#FF3131",
        "PED_WALK": "#00FFFF", "EMERGENCY": "#FF00FF", "NIGHT_MODE": "#7DF9FF"
    }

    # Reverse the list so the first signal appears at the top of the graph
    signals.reverse()

    y_tickvals = []
    y_ticktext = []

    # Iterate through signals and add a vertical offset to stack them
    for i, sig in enumerate(signals):
        offset = i * 2.5  # Space each waveform by 2.5 units vertically
        
        # Add values for custom Y-axis labeling
        y_tickvals.append(offset + 0.5) 
        y_ticktext.append(f"<b>{sig}</b>")

        # Add the digital step trace
        fig.add_trace(go.Scatter(
            x=df["Time"],
            y=df[sig] + offset,
            mode='lines',
            line_shape='hv',  # Creates the square digital waveform (step-chart)
            name=sig,
            line=dict(color=colors.get(sig, "#FFFFFF"), width=2.5),
            fill='tozeroy',
            fillcolor='rgba(0,0,0,0)' # Transparent fill to maintain clean lines
        )) # <-- This is the parenthesis that usually goes missing!

    # 3. Modernize the Layout
    fig.update_layout(
        plot_bgcolor='#0E1117',
        paper_bgcolor='#0E1117',
        font=dict(color='#E0E0E0'),
        xaxis=dict(
            title="Simulation Time (ns)",
            showgrid=True,
            gridcolor='#2b2b2b',
            zeroline=False
        ),
        yaxis=dict(
            title="",
            tickvals=y_tickvals,
            ticktext=y_ticktext,
            showgrid=True,
            gridcolor='#2b2b2b',
            zeroline=False,
            fixedrange=True # Locks Y-axis zooming so labels stay aligned
        ),
        height=800,
        margin=dict(l=10, r=20, t=30, b=40),
        showlegend=False,
        hovermode="x unified",
        dragmode="pan"
    ) # <-- Or this one!

    # Render the chart
    st.plotly_chart(fig, use_container_width=True)

    # 4. Raw Data Expander (Updated to Pandas 2.1+ safe styling)
    with st.expander("🔍 View Raw CSV Hardware Log"):
        # We use .map (modern pandas) instead of .applymap to style the table
        try:
            st.dataframe(df.style.map(lambda x: "color: #00FF00;" if x == 1 else "color: #555555;", subset=signals), use_container_width=True)
        except AttributeError:
            # Fallback for older versions of Pandas
            st.dataframe(df.style.applymap(lambda x: "color: #00FF00;" if x == 1 else "color: #555555;", subset=signals), use_container_width=True)

else:
    st.info("👈 Waiting for simulation data. Click **Run Simulation** in the sidebar.")