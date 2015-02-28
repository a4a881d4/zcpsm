set ver_major 1
set ver_minor 0

proc zcpsmInterface {} {

	ipx::add_bus_interface IO [ipx::current_core]
	set_property abstraction_type_vlnv xilinx.com:user:zcpsmIO_rtl:1.0 [ipx::get_bus_interfaces IO -of_objects [ipx::current_core]]
	set_property bus_type_vlnv xilinx.com:user:zcpsmIO:1.0 [ipx::get_bus_interfaces IO -of_objects [ipx::current_core]]
	set_property interface_mode master [ipx::get_bus_interfaces IO -of_objects [ipx::current_core]]
	ipx::add_port_map write_strobe [ipx::get_bus_interfaces IO -of_objects [ipx::current_core]]
	set_property physical_name write_strobe [ipx::get_port_maps write_strobe -of_objects [ipx::get_bus_interfaces IO -of_objects [ipx::current_core]]]
	ipx::add_port_map read_strobe [ipx::get_bus_interfaces IO -of_objects [ipx::current_core]]
	set_property physical_name read_strobe [ipx::get_port_maps read_strobe -of_objects [ipx::get_bus_interfaces IO -of_objects [ipx::current_core]]]
	ipx::add_port_map port_id [ipx::get_bus_interfaces IO -of_objects [ipx::current_core]]
	set_property physical_name port_id [ipx::get_port_maps port_id -of_objects [ipx::get_bus_interfaces IO -of_objects [ipx::current_core]]]
	ipx::add_port_map in_port [ipx::get_bus_interfaces IO -of_objects [ipx::current_core]]
	set_property physical_name in_port [ipx::get_port_maps in_port -of_objects [ipx::get_bus_interfaces IO -of_objects [ipx::current_core]]]
	ipx::add_port_map out_port [ipx::get_bus_interfaces IO -of_objects [ipx::current_core]]
	set_property physical_name out_port [ipx::get_port_maps out_port -of_objects [ipx::get_bus_interfaces IO -of_objects [ipx::current_core]]]
	
	ipx::add_bus_interface prog [ipx::current_core]
	set_property abstraction_type_vlnv xilinx.com:user:zcpsmProgBus_rtl:1.0 [ipx::get_bus_interfaces prog -of_objects [ipx::current_core]]
	set_property bus_type_vlnv xilinx.com:user:zcpsmProgBus:1.0 [ipx::get_bus_interfaces prog -of_objects [ipx::current_core]]
	set_property interface_mode master [ipx::get_bus_interfaces prog -of_objects [ipx::current_core]]
	ipx::add_port_map instruction [ipx::get_bus_interfaces prog -of_objects [ipx::current_core]]
	set_property physical_name instruction [ipx::get_port_maps instruction -of_objects [ipx::get_bus_interfaces prog -of_objects [ipx::current_core]]]
	ipx::add_port_map address [ipx::get_bus_interfaces prog -of_objects [ipx::current_core]]
	set_property physical_name address [ipx::get_port_maps address -of_objects [ipx::get_bus_interfaces prog -of_objects [ipx::current_core]]]


}

proc zcpsmISPInterface {} {}

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
	${top}Interface 
	ipx::create_xgui_files [ipx::current_core]
	ipx::update_checksums [ipx::current_core]
	ipx::save_core [ipx::current_core]
	append fn ../lib/xilinx.com_user_ $top _ $::ver_major . $::ver_minor .zip
	put $fn
	ipx::archive_core $fn [ipx::current_core]
	close_project
	#file delete -force $dir
}

file mkdir ../lib
#buildip zcpsm
buildip zcpsmISP

