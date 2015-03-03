set dir ../proj/Q7Led
	if [file exists $dir] {
		file delete -force $dir
	}
	
create_project Q7Led ../proj/Q7Led -part xc7z030ffg676-1
set_property target_language VHDL [current_project]
set_property ip_repo_paths  ../lib [current_project]

update_ip_catalog -rebuild
update_ip_catalog -add_ip ../lib/xilinx.com_user_zcpsmISP_1.0.zip -repo_path ../lib
update_ip_catalog -add_ip ../lib/xilinx.com_user_zOutReg_1.0.zip -repo_path ../lib
update_ip_catalog -add_ip ../lib/xilinx.com_user_zProg2Bram_1.0.zip -repo_path ../lib
create_bd_design "Q7Led"

# Arm system
	startgroup
	create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 arm
	endgroup
	startgroup
	set_property -dict [list CONFIG.PCW_SDIO_PERIPHERAL_FREQMHZ {50} CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {40} CONFIG.PCW_UIPARAM_DDR_ENABLE {1} CONFIG.PCW_UIPARAM_DDR_PARTNO {MT41K256M16 RE-125} CONFIG.PCW_SD0_PERIPHERAL_ENABLE {1} CONFIG.PCW_SD0_GRP_CD_ENABLE {1} CONFIG.PCW_SD0_GRP_CD_IO {MIO 46} CONFIG.PCW_SD0_GRP_WP_ENABLE {1} CONFIG.PCW_SD0_GRP_WP_IO {MIO 47} CONFIG.PCW_SD0_GRP_POW_ENABLE {1} CONFIG.PCW_SD0_GRP_POW_IO {MIO 48} CONFIG.PCW_USB0_PERIPHERAL_ENABLE {1}] [get_bd_cells arm]
	endgroup
	startgroup
	set_property -dict [list CONFIG.PCW_UART0_PERIPHERAL_ENABLE {0} CONFIG.PCW_UART1_PERIPHERAL_ENABLE {1} CONFIG.PCW_UART1_UART1_IO {MIO 52 .. 53}] [get_bd_cells arm]
	endgroup
	startgroup
	create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.0 armbus
	endgroup
	startgroup
	set_property -dict [list CONFIG.PROTOCOL {AXI4LITE} CONFIG.SINGLE_PORT_BRAM {1} CONFIG.ECC_TYPE {0}] [get_bd_cells armbus]
	endgroup
	startgroup
	
	create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR
	connect_bd_intf_net [get_bd_intf_pins arm/DDR] [get_bd_intf_ports DDR]
	endgroup
	startgroup
	
	create_bd_intf_port -mode Master -vlnv xilinx.com:display_processing_system7:fixedio_rtl:1.0 FIXED_IO
	connect_bd_intf_net [get_bd_intf_pins arm/FIXED_IO] [get_bd_intf_ports FIXED_IO]
	endgroup
	startgroup
	
	apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/arm/M_AXI_GP0" Clk "Auto" }  [get_bd_intf_pins armbus/S_AXI]


startgroup
create_bd_cell -type ip -vlnv xilinx.com:user:zcpsmISP:1.0 zcpsmISP_0
endgroup
startgroup
create_bd_cell -type ip -vlnv xilinx.com:user:zProg2Bram:1.0 zProg2Bram_0
endgroup
connect_bd_intf_net [get_bd_intf_pins zProg2Bram_0/ISP] [get_bd_intf_pins zcpsmISP_0/ISP]
connect_bd_intf_net [get_bd_intf_pins zProg2Bram_0/armBus] [get_bd_intf_pins armbus/BRAM_PORTA]

startgroup
create_bd_cell -type ip -vlnv xilinx.com:user:zOutReg:1.0 zOutReg_0
endgroup
set_property -dict [list CONFIG.port_ixd {1}] [get_bd_cells zOutReg_0]
connect_bd_net [get_bd_pins zOutReg_0/out_port] [get_bd_pins zcpsmISP_0/out_port]
connect_bd_net [get_bd_pins zOutReg_0/write_strobe] [get_bd_pins zcpsmISP_0/write_strobe]
connect_bd_net [get_bd_pins zOutReg_0/port_id] [get_bd_pins zcpsmISP_0/port_id]
startgroup
set_property -dict [list CONFIG.PROG {E:\zhaom\works\zcpsm\.work\ledrom.bit}] [get_bd_cells zcpsmISP_0]
endgroup

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

# connect_bd_net [get_bd_pins zcpsmISP_0/prog_clk] [get_bd_pins armbus/BRAM_PORTA_clk]



startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_1
endgroup
connect_bd_net [get_bd_pins xlslice_1/Din] [get_bd_pins zOutReg_0/Q]
startgroup
set_property -dict [list CONFIG.DIN_WIDTH {8} CONFIG.DIN_TO {4} CONFIG.DIN_FROM {7} CONFIG.DOUT_WIDTH {4}] [get_bd_cells xlslice_1]
endgroup
create_bd_port -dir O -from 3 -to 0 TEST_LED
connect_bd_net [get_bd_ports TEST_LED] [get_bd_pins xlslice_1/Dout]

regenerate_bd_layout
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_0
endgroup
connect_bd_net [get_bd_pins xlconstant_0/dout] [get_bd_pins zcpsmISP_0/reset]
startgroup
set_property -dict [list CONFIG.CONST_VAL {0}] [get_bd_cells xlconstant_0]
endgroup

startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:5.1 clk_wiz_0
endgroup
startgroup
set_property -dict [list CONFIG.PRIM_IN_FREQ.VALUE_SRC USER] [get_bd_cells clk_wiz_0]
set_property -dict [list CONFIG.PRIM_IN_FREQ {25} CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {40} CONFIG.CLKIN1_JITTER_PS {400.0} CONFIG.MMCM_CLKFBOUT_MULT_F {40.000} CONFIG.MMCM_CLKIN1_PERIOD {40.0} CONFIG.MMCM_CLKOUT0_DIVIDE_F {25.000} CONFIG.CLKOUT1_JITTER {293.769} CONFIG.CLKOUT1_PHASE_ERROR {237.727}] [get_bd_cells clk_wiz_0]
endgroup

startgroup
create_bd_port -dir I -type clk FPGA_CLK
set_property CONFIG.FREQ_HZ 25000000 [get_bd_ports FPGA_CLK]
endgroup
connect_bd_net [get_bd_ports FPGA_CLK] [get_bd_pins clk_wiz_0/clk_in1]
# connect_bd_net -net [get_bd_nets clk_wiz_0_clk_out1] [get_bd_pins zOutReg_0/zClk] [get_bd_pins clk_wiz_0/clk_out1]

connect_bd_net -net [get_bd_nets xlconstant_0_dout] [get_bd_pins clk_wiz_0/reset] [get_bd_pins xlconstant_0/dout]
# connect_bd_net [get_bd_pins armbus/bram_clk_a] [get_bd_pins zcpsmISP_0/prog_clk]

save_bd_design

make_wrapper -files [get_files ../proj/Q7Led/Q7Led.srcs/sources_1/bd/Q7Led/Q7Led.bd] -top

add_files -norecurse ../proj/Q7Led/Q7Led.srcs/sources_1/bd/Q7Led/hdl/Q7Led_wrapper.vhd
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

add_files -fileset constrs_1 -norecurse ../src/example/Q7Led/xdc/Q7.xdc
import_files -fileset constrs_1 ../src/example/Q7Led/xdc/Q7.xdc

close_project