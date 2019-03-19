proc adi_ip_files {ip_name ip_files} {

  global ip_constr_files

  set ip_constr_files ""
  foreach m_file $ip_files {
    if {[file extension $m_file] eq ".xdc"} {
      lappend ip_constr_files $m_file
    }
  }

  set proj_fileset [get_filesets sources_1]
  add_files -norecurse -scan_for_includes -fileset $proj_fileset $ip_files
  set_property "top" "$ip_name" $proj_fileset
}
set ip_name axi_datatran

cd ../ip_repo/$ip_name/
file delete -force tmpprj/
file delete -force ipcfg/
file mkdir tmpprj/
file mkdir ipcfg/
cd tmpprj/

create_project $ip_name . -force
source ../../../scripts/adi_xilinx_msg.tcl

adi_ip_files $ip_name [list \
    "../src/signalch.v" \
    "../src/datawr.v" \
    "../src/pwm_control.v"  \
    "../src/top/$ip_name.v"  ]

ipx::package_project -root_dir ../ipcfg/ -vendor user.com -library user -taxonomy /FlyLower ;#-archive_source_project true
set_property name $ip_name [ipx::current_core]
#set_property display_name $ip_name [ipx::current_core]
set_property vendor_display_name {FlyLower} [ipx::current_core]
set_property company_url {http://www.user.com} [ipx::current_core]

set i_families ""
foreach i_part [get_parts] {
    lappend i_families [get_property FAMILY $i_part]
}
set i_families [lsort -unique $i_families]
set s_families [get_property supported_families [ipx::current_core]]
foreach i_family $i_families {
    set s_families "$s_families $i_family Production"
    set s_families "$s_families $i_family Beta"
}
set_property supported_families $s_families [ipx::current_core]

ipx::remove_all_bus_interface [ipx::current_core]

set i_filegroup [ipx::get_file_groups -of_objects [ipx::current_core] -filter {NAME =~ *synthesis*}]
foreach i_file $ip_constr_files {
    set i_module [file tail $i_file]
    regsub {_constr\.xdc} $i_module {} i_module
    ipx::add_file $i_file $i_filegroup
    ipx::reorder_files -front $i_file $i_filegroup
    set_property SCOPED_TO_REF $i_module [ipx::get_files $i_file -of_objects $i_filegroup]
}

set memory_maps [ipx::get_memory_maps * -of_objects [ipx::current_core]]
  foreach map $memory_maps {
    ipx::remove_memory_map [lindex $map 2] [ipx::current_core ]
  }

  ipx::infer_bus_interface {\
    axi4lite_ext_awvalid \
    axi4lite_ext_awaddr \
    axi4lite_ext_awprot \
    axi4lite_ext_awready \
    axi4lite_ext_wvalid \
    axi4lite_ext_wdata \
    axi4lite_ext_wstrb \
    axi4lite_ext_wready \
    axi4lite_ext_bvalid \
    axi4lite_ext_bresp \
    axi4lite_ext_bready \
    axi4lite_ext_arvalid \
    axi4lite_ext_araddr \
    axi4lite_ext_arprot \
    axi4lite_ext_arready \
    axi4lite_ext_rvalid \
    axi4lite_ext_rdata \
    axi4lite_ext_rresp \
    axi4lite_ext_rready} \
  xilinx.com:interface:aximm_rtl:1.0 [ipx::current_core]

  ipx::infer_bus_interface axi4lite_ext_aclk xilinx.com:signal:clock_rtl:1.0 [ipx::current_core]
  ipx::infer_bus_interface axi4lite_ext_aresetn xilinx.com:signal:reset_rtl:1.0 [ipx::current_core]

  set raddr_width [expr [get_property SIZE_LEFT [ipx::get_ports -nocase true axi4lite_ext_araddr -of_objects [ipx::current_core]]] + 1]
  set waddr_width [expr [get_property SIZE_LEFT [ipx::get_ports -nocase true axi4lite_ext_awaddr -of_objects [ipx::current_core]]] + 1]

  if {$raddr_width != $waddr_width} {
    puts [format "WARNING: AXI address width mismatch for %s (r=%d, w=%d)" $ip_name $raddr_width, $waddr_width]
    set range 65536
  } else {
    if {$raddr_width >= 16} {
      set range 65536
    } else {
      set range [expr 1 << $raddr_width]
    }
  }

  ipx::add_memory_map {axi4lite_ext} [ipx::current_core]
  set_property slave_memory_map_ref {axi4lite_ext} [ipx::get_bus_interfaces axi4lite_ext -of_objects [ipx::current_core]]
  ipx::add_address_block {axi4lite_ext} [ipx::get_memory_maps axi4lite_ext -of_objects [ipx::current_core]]
  set_property range $range [ipx::get_address_blocks axi4lite_ext\
    -of_objects [ipx::get_memory_maps axi4lite_ext -of_objects [ipx::current_core]]]
  ipx::add_bus_parameter ASSOCIATED_BUSIF [ipx::get_bus_interfaces axi4lite_ext_aclk \
    -of_objects [ipx::current_core]]
  set_property value axi4lite_ext [ipx::get_bus_parameters ASSOCIATED_BUSIF \
    -of_objects [ipx::get_bus_interfaces axi4lite_ext_aclk \
    -of_objects [ipx::current_core]]]
# ipx::add_address_block_parameter OFFSET_BASE_PARAM [ipx::get_address_blocks axi4lite_ext -of_objects [ipx::get_memory_maps axi4lite_ext -of_objects [ipx::current_core]]]
# set_property value "C_S_AXI_BASEADDR" [ipx::get_address_block_parameter OFFSET_BASE_PARAM [ipx::get_address_blocks axi4lite_ext -of_objects [ipx::get_memory_maps axi4lite_ext -of_objects [ipx::current_core]]]]
# ipx::add_address_block_parameter OFFSET_HIGH_PARAM [ipx::get_address_blocks axi4lite_ext -of_objects [ipx::get_memory_maps axi4lite_ext -of_objects [ipx::current_core]]]
# set_property value "C_S_AXI_HIGHADDR" [ipx::get_address_block_parameter OFFSET_HIGH_PARAM [ipx::get_address_blocks axi4lite_ext -of_objects [ipx::get_memory_maps axi4lite_ext -of_objects [ipx::current_core]]]]

ipx::add_bus_interface RX [ipx::current_core]
set_property abstraction_type_vlnv xilinx.com:interface:bram_rtl:1.0 [ipx::get_bus_interfaces RX -of_objects [ipx::current_core]]
set_property bus_type_vlnv xilinx.com:interface:bram:1.0 [ipx::get_bus_interfaces RX -of_objects [ipx::current_core]]
set_property interface_mode master [ipx::get_bus_interfaces RX -of_objects [ipx::current_core]]
ipx::add_port_map EN [ipx::get_bus_interfaces RX -of_objects [ipx::current_core]]
set_property physical_name en_rd [ipx::get_port_maps EN -of_objects [ipx::get_bus_interfaces RX -of_objects [ipx::current_core]]]
ipx::add_port_map RST [ipx::get_bus_interfaces RX -of_objects [ipx::current_core]]
set_property physical_name rst [ipx::get_port_maps RST -of_objects [ipx::get_bus_interfaces RX -of_objects [ipx::current_core]]]
ipx::add_port_map DOUT [ipx::get_bus_interfaces RX -of_objects [ipx::current_core]]
set_property physical_name din_b [ipx::get_port_maps DOUT -of_objects [ipx::get_bus_interfaces RX -of_objects [ipx::current_core]]]
ipx::add_port_map CLK [ipx::get_bus_interfaces RX -of_objects [ipx::current_core]]
set_property physical_name clk [ipx::get_port_maps CLK -of_objects [ipx::get_bus_interfaces RX -of_objects [ipx::current_core]]]
ipx::add_port_map WE [ipx::get_bus_interfaces RX -of_objects [ipx::current_core]]
set_property physical_name we_rd [ipx::get_port_maps WE -of_objects [ipx::get_bus_interfaces RX -of_objects [ipx::current_core]]]
ipx::add_port_map ADDR [ipx::get_bus_interfaces RX -of_objects [ipx::current_core]]
set_property physical_name addr_a [ipx::get_port_maps ADDR -of_objects [ipx::get_bus_interfaces RX -of_objects [ipx::current_core]]]
ipx::add_bus_parameter MASTER_TYPE [ipx::get_bus_interfaces RX -of_objects [ipx::current_core]]
set_property value BRAM_CTRL [ipx::get_bus_parameter MASTER_TYPE [ipx::get_bus_interfaces RX -of_objects [ipx::current_core]]]
ipx::add_bus_parameter READ_WRITE_MODE [ipx::get_bus_interfaces RX -of_objects [ipx::current_core]]
set_property value READ_ONLY [ipx::get_bus_parameter READ_WRITE_MODE [ipx::get_bus_interfaces RX -of_objects [ipx::current_core]]]
ipx::add_bus_parameter READ_LATENCY [ipx::get_bus_interfaces RX -of_objects [ipx::current_core]]
set_property value 1 [ipx::get_bus_parameter READ_LATENCY [ipx::get_bus_interfaces RX -of_objects [ipx::current_core]]]

ipx::add_bus_interface TX [ipx::current_core]
set_property abstraction_type_vlnv xilinx.com:interface:bram_rtl:1.0 [ipx::get_bus_interfaces TX -of_objects [ipx::current_core]]
set_property bus_type_vlnv xilinx.com:interface:bram:1.0 [ipx::get_bus_interfaces TX -of_objects [ipx::current_core]]
set_property interface_mode master [ipx::get_bus_interfaces TX -of_objects [ipx::current_core]]
ipx::add_port_map EN [ipx::get_bus_interfaces TX -of_objects [ipx::current_core]]
set_property physical_name en_wr [ipx::get_port_maps EN -of_objects [ipx::get_bus_interfaces TX -of_objects [ipx::current_core]]]
ipx::add_port_map RST [ipx::get_bus_interfaces TX -of_objects [ipx::current_core]]
set_property physical_name rst [ipx::get_port_maps RST -of_objects [ipx::get_bus_interfaces TX -of_objects [ipx::current_core]]]
ipx::add_port_map DIN [ipx::get_bus_interfaces TX -of_objects [ipx::current_core]]
set_property physical_name outsig_o [ipx::get_port_maps DIN -of_objects [ipx::get_bus_interfaces TX -of_objects [ipx::current_core]]]
ipx::add_port_map CLK [ipx::get_bus_interfaces TX -of_objects [ipx::current_core]]
set_property physical_name clk [ipx::get_port_maps CLK -of_objects [ipx::get_bus_interfaces TX -of_objects [ipx::current_core]]]
ipx::add_port_map WE [ipx::get_bus_interfaces TX -of_objects [ipx::current_core]]
set_property physical_name we_wr [ipx::get_port_maps WE -of_objects [ipx::get_bus_interfaces TX -of_objects [ipx::current_core]]]
ipx::add_port_map ADDR [ipx::get_bus_interfaces TX -of_objects [ipx::current_core]]
set_property physical_name addr_b [ipx::get_port_maps ADDR -of_objects [ipx::get_bus_interfaces TX -of_objects [ipx::current_core]]]
ipx::add_bus_parameter MASTER_TYPE [ipx::get_bus_interfaces TX -of_objects [ipx::current_core]]
set_property value BRAM_CTRL [ipx::get_bus_parameter MASTER_TYPE [ipx::get_bus_interfaces TX -of_objects [ipx::current_core]]]
ipx::add_bus_parameter READ_WRITE_MODE [ipx::get_bus_interfaces TX -of_objects [ipx::current_core]]
set_property value WRITE_ONLY [ipx::get_bus_parameter READ_WRITE_MODE [ipx::get_bus_interfaces TX -of_objects [ipx::current_core]]]
#ipx::add_bus_parameter READ_LATENCY [ipx::get_bus_interfaces TX -of_objects [ipx::current_core]]
#set_property value 1 [ipx::get_bus_parameter READ_LATENCY [ipx::get_bus_interfaces RX -of_objects [ipx::current_core]]]

ipgui::remove_param -component [ipx::current_core] [ipgui::get_guiparamspec -name "C_S_AXI_DATA_WIDTH" -component [ipx::current_core]]
ipgui::remove_param -component [ipx::current_core] [ipgui::get_guiparamspec -name "C_S_AXI_ADDR_WIDTH" -component [ipx::current_core]]

set rev [get_property core_revision [ipx::current_core]]
set_property core_revision [expr $rev+1] [ipx::current_core]

# if 0 {
ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::save_core [ipx::current_core]
close_project ;#-delete
cd ../../../scripts/
# }

exit