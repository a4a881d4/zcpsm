file delete -force ../lib
file mkdir ../lib

source buildInterface.tcl
source buildQ7.tcl
source buildIP.tcl

set dir ../proj/Q7Led
	if [file exists $dir] {
		file delete -force $dir
	}
create_project Q7Led ../proj/Q7Led -part xc7z030ffg676-1
set_property target_language VHDL [current_project]
set_property ip_repo_paths  ../lib [current_project]

update_ip_catalog -rebuild
update_ip_catalog -add_ip ../lib/xilinx.com_user_Q7ARM_BUS0_1.0.zip -repo_path ../lib
update_ip_catalog -add_ip ../lib/xilinx.com_user_zcpsmISP_1.0.zip -repo_path ../lib
update_ip_catalog -add_ip ../lib/xilinx.com_user_zOutReg_1.0.zip -repo_path ../lib
update_ip_catalog -add_ip ../lib/xilinx.com_user_zProg2Bram_1.0.zip -repo_path ../lib
create_bd_design "Q7Led"
startgroup
create_bd_cell -type ip -vlnv xilinx.com:user:ARM_wrapper:1.0 ARM_wrapper_0
endgroup
startgroup
create_bd_intf_port -mode Slave -vlnv xilinx.com:display_processing_system7:fixedio_rtl:1.0 FIXED_IO
connect_bd_intf_net [get_bd_intf_pins ARM_wrapper_0/FIXED_IO] [get_bd_intf_ports FIXED_IO]
endgroup
startgroup
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR
connect_bd_intf_net [get_bd_intf_pins ARM_wrapper_0/DDR] [get_bd_intf_ports DDR]
endgroup
startgroup
create_bd_cell -type ip -vlnv xilinx.com:user:zcpsmISP:1.0 zcpsmISP_0
endgroup
startgroup
create_bd_cell -type ip -vlnv xilinx.com:user:zProg2Bram:1.0 zProg2Bram_0
endgroup
connect_bd_intf_net [get_bd_intf_pins zProg2Bram_0/ISP] [get_bd_intf_pins zcpsmISP_0/ISP]
connect_bd_intf_net [get_bd_intf_pins zProg2Bram_0/armBus] [get_bd_intf_pins ARM_wrapper_0/BRAM_PORTA]
regenerate_bd_layout
startgroup
create_bd_cell -type ip -vlnv xilinx.com:user:zOutReg:1.0 zOutReg_0
endgroup
set_property -dict [list CONFIG.port_ixd {1}] [get_bd_cells zOutReg_0]
connect_bd_net [get_bd_pins zOutReg_0/out_port] [get_bd_pins zcpsmISP_0/out_port]
connect_bd_net [get_bd_pins zOutReg_0/write_strobe] [get_bd_pins zcpsmISP_0/write_strobe]
connect_bd_net [get_bd_pins zOutReg_0/port_id] [get_bd_pins zcpsmISP_0/port_id]
connect_bd_net [get_bd_pins ARM_wrapper_0/BRAM_PORTA_clk] [get_bd_pins zcpsmISP_0/clk]
connect_bd_net -net [get_bd_nets ARM_wrapper_0_BRAM_PORTA_clk] [get_bd_pins zOutReg_0/zClk] [get_bd_pins ARM_wrapper_0/BRAM_PORTA_clk]

startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_0
endgroup
delete_bd_objs [get_bd_cells xlconcat_0]
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_0
endgroup
delete_bd_objs [get_bd_nets zcpsmISP_0_port_ce]
connect_bd_net [get_bd_pins zcpsmISP_0/port_ce] [get_bd_pins xlslice_0/Din]
connect_bd_net [get_bd_pins xlslice_0/Dout] [get_bd_pins zOutReg_0/port_ce]
startgroup
set_property -dict [list CONFIG.DIN_WIDTH {16}] [get_bd_cells xlslice_0]
endgroup

startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_1
endgroup
connect_bd_net [get_bd_pins xlslice_1/Din] [get_bd_pins zOutReg_0/Q]
startgroup
set_property -dict [list CONFIG.DIN_WIDTH {8} CONFIG.DIN_TO {4} CONFIG.DIN_FROM {7} CONFIG.DOUT_WIDTH {4}] [get_bd_cells xlslice_1]
endgroup
create_bd_port -dir O -from 3 -to 0 Test
connect_bd_net [get_bd_ports Test] [get_bd_pins xlslice_1/Dout]

regenerate_bd_layout
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_0
endgroup
connect_bd_net [get_bd_pins xlconstant_0/dout] [get_bd_pins zcpsmISP_0/reset]
startgroup
set_property -dict [list CONFIG.CONST_VAL {0}] [get_bd_cells xlconstant_0]
endgroup

save_bd_design

close_project