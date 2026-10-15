# run_sim.ps1
Write-Host "🚧 Compiling SystemVerilog RTL and Testbench..." -ForegroundColor Cyan
iverilog -g2012 -o traffic_sim.vvp rtl/traffic_fsm.sv rtl/top.sv tb/traffic_tb.sv

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Compilation Successful! Running Simulation..." -ForegroundColor Green
    vvp traffic_sim.vvp
    
    Write-Host "📈 Opening GTKWave..." -ForegroundColor Yellow
    gtkwave traffic.vcd
} else {
    Write-Host "❌ Compilation Failed. Check syntax errors above." -ForegroundColor Red
}