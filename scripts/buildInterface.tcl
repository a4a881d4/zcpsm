proc buildInterface { interface ports } {

	create_project Interface_$interface -in_memory -part xc7z030ffg676-1
	set_property target_language VHDL [current_project]
	set_property ip_repo_paths  ../lib [current_project]
	ipx::create_abstraction_definition xilinx.com user ${interface}_rtl 1.0
	ipx::create_bus_definition xilinx.com user $interface 1.0
	set_property xml_file_name ../lib/${interface}_rtl.xml [ipx::current_busabs]
	set_property xml_file_name ../lib/${interface}.xml [ipx::current_busdef]
	set_property bus_type_vlnv xilinx.com:user:${interface}:1.0 [ipx::current_busabs]
	set_property display_name ${interface} [ipx::current_busdef]
	set_property display_name ${interface} [ipx::current_busabs]
	foreach portset $ports {
		
		array set port $portset
		#put [ array get port ]
		set name $port(name)
		#put $name
		
		ipx::add_bus_abstraction_port $name [ipx::current_busabs]
		set_property master_direction $port(master_direction) [ipx::get_bus_abstraction_ports $name -of_objects [ipx::current_busabs]]
		set_property slave_direction $port(slave_direction) [ipx::get_bus_abstraction_ports $name -of_objects [ipx::current_busabs]]
		set_property master_width $port(width) [ipx::get_bus_abstraction_ports $name -of_objects [ipx::current_busabs]]
		set_property slave_width $port(width) [ipx::get_bus_abstraction_ports $name -of_objects [ipx::current_busabs]]
	
	}
	ipx::save_abstraction_definition [ipx::current_busabs]
	ipx::save_bus_definition [ipx::current_busdef]
	
	close_project
	
}

file mkdir ../lib

#port_id 	:	out std_logic_vector(7 downto 0);
#write_strobe :	out std_logic;
#out_port 	:	out std_logic_vector(7 downto 0);
#read_strobe :	out std_logic;
#in_port 	:	in std_logic_vector(7 downto 0);


set zcpsmIO {
	{
		name port_id
		master_direction out
		slave_direction in
		width 8
	}
	{
		name write_strobe
		master_direction out
		slave_direction in
		width 1
	}
	{
		name out_port
		master_direction out
		slave_direction in
		width 8
	}
	{
		name read_strobe
		master_direction out
		slave_direction in
		width 1
	}
	{
		name in_port
		master_direction in
		slave_direction out
		width 8
	}
}

buildInterface zcpsmIO $zcpsmIO

#address 	: 	out std_logic_vector(11 downto 0);
#instruction :	in std_logic_vector(17 downto 0);

set zcpsmProgBus {
	{
		name address
		master_direction out
		slave_direction in
		width 12
	}
	{
		name instruction
		master_direction in
		slave_direction out
		width 18
	}
}

buildInterface zcpsmProgBus $zcpsmProgBus


#		prog_we	: in std_logic;
#		prog_clk: in std_logic;
#		prog_addr : in std_logic_vector( AWIDTH-1 downto 0 );
#		prog_din : in std_logic_vector( 17 downto 0 )

set zcpsmISPBus {
	{
		name prog_addr
		master_direction out
		slave_direction in
		width -1
	}
	{
		name prog_we
		master_direction out
		slave_direction in
		width 1
	}
	{
		name prog_data
		master_direction out
		slave_direction in
		width 18
	}
}

buildInterface zcpsmISPBus $zcpsmISPBus

set zcpsmBus {
	{
		name port_ce
		master_direction out
		slave_direction in
		width 16
	}
	{
		name port_id
		master_direction out
		slave_direction in
		width 4
	}
	{
		name write_strobe
		master_direction out
		slave_direction in
		width 1
	}
	{
		name out_port
		master_direction out
		slave_direction in
		width 8
	}
	{
		name read_strobe
		master_direction out
		slave_direction in
		width 1
	}
	{
		name in_port
		master_direction in
		slave_direction out
		width 8
	}
}

buildInterface zcpsmBus $zcpsmBus