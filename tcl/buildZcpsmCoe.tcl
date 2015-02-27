set ver_major 1
set ver_minor 0

set processor [lindex $argv 0]
set coe {}  
append coe [pwd] / [lindex $argv 1]
set bdname ${processor}_zcpsm  

proc buildip { top } {
	set dir ../proj/$top
	if [file exists $dir] {
		file delete -force $dir
	}
	create_project $top ../proj/$top -part xc7z030ffg676-1
	set_property target_language VHDL [current_project]
	set_property ip_repo_paths  ../lib [current_project]
	update_ip_catalog -rebuild
	add_files ../src/zcpsm
	import_files -force
	update_compile_order -fileset sources_1
	set_property top $top [current_fileset]
	update_compile_order -fileset sources_1
	append ipdir ../proj / $top / $top .srcs/sources_1/imports
	put $ipdir
	ipx::package_project -root_dir $ipdir
	set_property library user [ipx::current_core]
	set_property taxonomy /UserIP [ipx::current_core]
	set_property vendor_display_name a4a881d4 [ipx::current_core]
	set_property company_url http://github.com/a4a881d4/ringbus4xilinx [ipx::current_core]
	set_property core_revision 1 [ipx::current_core]
	zcpsmInterface 
	ipx::create_xgui_files [ipx::current_core]
	ipx::update_checksums [ipx::current_core]
	ipx::save_core [ipx::current_core]
	append fn ../lib/xilinx.com_user_ $top _ $::ver_major . $::ver_minor .zip
	put $fn
	ipx::archive_core $fn [ipx::current_core]
	close_project
	#file delete -force $dir
}

set dir ../proj/$bdname
if [file exists $dir] {
	file delete -force $dir
}

create_project $bdname $dir -part xc7z030ffg676-1
set_property target_language VHDL [current_project]
set_property ip_repo_paths  ../lib [current_project]
update_ip_catalog -rebuild

create_bd_design $bdname
startgroup
create_bd_cell -type ip -vlnv xilinx.com:user:zcpsm:1.0 zcpsm_0
endgroup
startgroup
create_bd_intf_port -mode Master -vlnv xilinx.com:user:zcpsmIO_rtl:1.0 IO
connect_bd_intf_net [get_bd_intf_pins zcpsm_0/IO] [get_bd_intf_ports IO]
endgroup
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.2 blk_mem_gen_0
endgroup
startgroup
set_property -dict [list CONFIG.Memory_Type {Single_Port_ROM} CONFIG.Write_Width_A {18} CONFIG.Write_Depth_A {1024} CONFIG.Enable_A {Always_Enabled} CONFIG.Register_PortA_Output_of_Memory_Primitives {false} CONFIG.Register_PortA_Output_of_Memory_Core {true} CONFIG.Load_Init_File {true} CONFIG.Coe_File $coe CONFIG.use_bram_block {Stand_Alone} CONFIG.Enable_32bit_Address {false} CONFIG.Use_Byte_Write_Enable {false} CONFIG.Byte_Size {9} CONFIG.Read_Width_A {18} CONFIG.Write_Width_B {18} CONFIG.Read_Width_B {18} CONFIG.Use_RSTA_Pin {false} CONFIG.Port_A_Write_Rate {0}] [get_bd_cells blk_mem_gen_0]
endgroup
startgroup
create_bd_port -dir I -type clk clk
connect_bd_net [get_bd_pins /zcpsm_0/clk] [get_bd_ports clk]
endgroup
startgroup
create_bd_port -dir I -type rst reset
connect_bd_net [get_bd_pins /zcpsm_0/reset] [get_bd_ports reset]
endgroup
connect_bd_net -net [get_bd_nets clk_1] [get_bd_ports clk] [get_bd_pins blk_mem_gen_0/clka]
connect_bd_net [get_bd_pins blk_mem_gen_0/douta] [get_bd_pins zcpsm_0/instruction]
connect_bd_net [get_bd_pins zcpsm_0/address] [get_bd_pins blk_mem_gen_0/addra]
regenerate_bd_layout
save_bd_design

set fn ../proj/$bdname/$bdname
append fn .srcs/sources_1/bd/ $bdname / $bdname .bd
generate_target all [get_files  $fn]

ipx::package_project -module $bdname
set_property library user [ipx::current_core]
set_property taxonomy /UserIP [ipx::current_core]
set_property vendor_display_name a4a881d4 [ipx::current_core]
set_property company_url http://github.com/a4a881d4/ringbus4xilinx [ipx::current_core]
set_property core_revision 1 [ipx::current_core]

ipx::save_core [ipx::current_core]
unset fn
append fn ../lib/xilinx.com_user_ $bdname _ $::ver_major . $::ver_minor .zip
put $fn
ipx::archive_core $fn [ipx::current_core]
close_project
