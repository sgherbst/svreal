# Create the Vivado project
# ZC702: xc7z020clg484-1
# PYNQ: xc7z020clg400-1
create_project -force proj_test_ops proj_test_ops -part "xc7z020clg484-1"

# Add files
add_files "test_ops.sv"
add_files "../svreal.sv"
set_property file_type "Verilog Header" [get_files "../svreal.sv"]

# Config the simulation
set_property -name top -value test_ops -objects [get_fileset sim_1]
set_property -name {xsim.simulate.runtime} -value {-all} -objects [get_fileset sim_1]

# Run the simulation
launch_simulation
