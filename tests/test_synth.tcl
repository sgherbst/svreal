# Create the Vivado project
# ZC702: xc7z020clg484-1
# PYNQ: xc7z020clg400-1
create_project -force proj_test_synth proj_test_synth -part "xc7z020clg484-1"

# Add source files
add_files "test_synth.sv"
add_files "../svreal.sv"
set_property file_type "Verilog Header" [get_files "../svreal.sv"]

# Set the top-level module
set_property -name top -value test_synth -objects [current_fileset]

# Run synthesis
launch_runs synth_1
wait_on_run synth_1
