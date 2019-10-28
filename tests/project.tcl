create_project -force project project
add_files "top.sv"
add_files "../svreal.sv"
set_property file_type "Verilog Header" [get_files "../svreal.sv"]
set_property -name top -value {top} -objects [get_fileset sim_1]
set_property -name {xsim.simulate.runtime} -value {-all} -objects [get_fileset sim_1]
launch_simulation
