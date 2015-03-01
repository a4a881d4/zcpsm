set ver_major 1
set ver_minor 0

proc buildip { top } {
	set dir ../proj/$top
	if [file exists $dir] {
		file delete -force $dir
	}
	create_project $top ../proj/$top -part xc7z030ffg676-1
	set_property target_language VHDL [current_project]
	set_property ip_repo_paths  ../lib [current_project]
	update_ip_catalog -rebuild
	
	create_bd_design "ARM"
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
	create_bd_intf_port -mode Master -vlnv xilinx.com:interface:bram_rtl:1.0 BRAM_PORTA
	set_property CONFIG.MASTER_TYPE [get_property CONFIG.MASTER_TYPE [get_bd_intf_pins armbus/BRAM_PORTA]] [get_bd_intf_ports BRAM_PORTA]
	connect_bd_intf_net [get_bd_intf_pins armbus/BRAM_PORTA] [get_bd_intf_ports BRAM_PORTA]
	endgroup
	apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/arm/M_AXI_GP0" Clk "Auto" }  [get_bd_intf_pins armbus/S_AXI]
	regenerate_bd_layout
	save_bd_design
	
	set fn {}
	append fn ../proj / $top / $top .srcs/sources_1/bd/ARM
	put $fn
	make_wrapper -files [get_files ${fn}/ARM.bd] -top
	add_files -norecurse ${fn}/hdl/ARM_wrapper.vhd
	update_compile_order -fileset sources_1
	update_compile_order -fileset sim_1
	ipx::package_project -root_dir $fn
	set_property library user [ipx::current_core]
	set_property taxonomy /UserIP [ipx::current_core]
	set_property vendor_display_name a4a881d4 [ipx::current_core]
	set_property company_url http://github.com/a4a881d4/zcpsm [ipx::current_core]
	set_property core_revision 1 [ipx::current_core]
	ipx::infer_bus_interfaces xilinx.com:display_processing_system7:fixedio_rtl:1.0 [ipx::current_core]
	ipx::infer_bus_interfaces xilinx.com:interface:ddrx_rtl:1.0 [ipx::current_core]
	ipx::infer_bus_interfaces xilinx.com:interface:bram_rtl:1.0 [ipx::current_core]
	ipx::create_xgui_files [ipx::current_core]
	ipx::update_checksums [ipx::current_core]
	ipx::save_core [ipx::current_core]
	set fn {}
	append fn ../lib/xilinx.com_user_ $top _ $::ver_major . $::ver_minor .zip
	put $fn
	ipx::archive_core $fn [ipx::current_core]
	close_project
}

buildip Q7ARM_BUS0


#