set_global_assignment -entity "u_vjtag" -library "lib_u_vjtag" -name IP_TOOL_NAME "Qsys"
set_global_assignment -entity "u_vjtag" -library "lib_u_vjtag" -name IP_TOOL_VERSION "20.1"
set_global_assignment -entity "u_vjtag" -library "lib_u_vjtag" -name IP_TOOL_ENV "Qsys"
set_global_assignment -library "lib_u_vjtag" -name SPD_FILE [file join $::quartus(sip_path) "../u_vjtag.spd"]
set_global_assignment -library "lib_u_vjtag" -name MISC_FILE [file join $::quartus(sip_path) "../../u_vjtag.qsys"]

set_global_assignment -library "lib_u_vjtag" -name MISC_FILE [file join $::quartus(sip_path) "u_vjtag.v"]
set_global_assignment -library "lib_u_vjtag" -name MISC_FILE [file join $::quartus(sip_path) "submodules/sld_virtual_jtag.v"]
