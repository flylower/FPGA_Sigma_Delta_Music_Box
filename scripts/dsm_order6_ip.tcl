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
set ip_name dsm_order6

cd ../ip_repo/$ip_name/
file delete -force tmpprj/
file delete -force ipcfg/
file mkdir tmpprj/
file mkdir ipcfg/
cd tmpprj/

create_project $ip_name . -force
source ../../../scripts/adi_xilinx_msg.tcl

adi_ip_files $ip_name [list \
    "../src/delay_integrator.v" \
    "../src/non_delay_integrator.v" \
    "../src/fac.v"  \
    "../src/fsclk_def.v"  \
    "../src/outs.v"  \
    "../src/gain.v"  \
    "../src/inpsig.v"  \
    "../src/xa.v"  \
    "../src/xb.v"  \
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
puts $i_families
foreach i_family $i_families {
    puts $i_family
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

ipgui::remove_param -component [ipx::current_core] [ipgui::get_guiparamspec -name "FAC1_CGAINA" -component [ipx::current_core]]
ipgui::remove_param -component [ipx::current_core] [ipgui::get_guiparamspec -name "FAC1_CGAINB" -component [ipx::current_core]]
ipgui::remove_param -component [ipx::current_core] [ipgui::get_guiparamspec -name "FAC1_CGAING" -component [ipx::current_core]]
ipgui::remove_param -component [ipx::current_core] [ipgui::get_guiparamspec -name "FAC2_CGAINA" -component [ipx::current_core]]
ipgui::remove_param -component [ipx::current_core] [ipgui::get_guiparamspec -name "FAC2_CGAINB" -component [ipx::current_core]]
ipgui::remove_param -component [ipx::current_core] [ipgui::get_guiparamspec -name "FAC2_CGAING" -component [ipx::current_core]]
ipgui::remove_param -component [ipx::current_core] [ipgui::get_guiparamspec -name "FAC3_CGAINA" -component [ipx::current_core]]
ipgui::remove_param -component [ipx::current_core] [ipgui::get_guiparamspec -name "FAC3_CGAINB" -component [ipx::current_core]]
ipgui::remove_param -component [ipx::current_core] [ipgui::get_guiparamspec -name "FAC3_CGAING" -component [ipx::current_core]]

set group_parent [ipgui::get_pagespec -name "Page 0" -component [ipx::current_core]] 
ipgui::add_group -name {FAC 1} -component [ipx::current_core] -parent $group_parent -display_name {FAC 1} -layout {horizontal}
set param_parent [ipgui::get_groupspec -name "FAC 1" -component [ipx::current_core]]
ipgui::add_param -name {FAC1_CGAINA} -component [ipx::current_core] -parent $param_parent
ipgui::add_param -name {FAC1_CGAINB} -component [ipx::current_core] -parent $param_parent
ipgui::add_param -name {FAC1_CGAING} -component [ipx::current_core] -parent $param_parent
ipgui::add_group -name {FAC 2} -component [ipx::current_core] -parent $group_parent -display_name {FAC 2} -layout {horizontal}
set param_parent [ipgui::get_groupspec -name "FAC 2" -component [ipx::current_core]]
ipgui::add_param -name {FAC2_CGAINA} -component [ipx::current_core] -parent $param_parent
ipgui::add_param -name {FAC2_CGAINB} -component [ipx::current_core] -parent $param_parent
ipgui::add_param -name {FAC2_CGAING} -component [ipx::current_core] -parent $param_parent
ipgui::add_group -name {FAC 3} -component [ipx::current_core] -parent $group_parent -display_name {FAC 3} -layout {horizontal}
set param_parent [ipgui::get_groupspec -name "FAC 3" -component [ipx::current_core]]
ipgui::add_param -name {FAC3_CGAINA} -component [ipx::current_core] -parent $param_parent
ipgui::add_param -name {FAC3_CGAINB} -component [ipx::current_core] -parent $param_parent
ipgui::add_param -name {FAC3_CGAING} -component [ipx::current_core] -parent $param_parent


ipx::infer_bus_interface clk xilinx.com:signal:clock_rtl:1.0 [ipx::current_core]
# ipx::add_bus_parameter FREQ_HZ [ipx::get_bus_interfaces clk -of_objects [ipx::current_core]]

ipx::infer_bus_interface rst_n xilinx.com:signal:reset_rtl:1.0 [ipx::current_core]  ;#default active low

set rev [get_property core_revision [ipx::current_core]]
set_property core_revision [expr $rev+1] [ipx::current_core]

ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::save_core [ipx::current_core]

#set_property  ip_repo_paths  c:/Users/WangFule/Documents/Wav_Play/iprepo/dsm_order6/ipcfg [current_project]
#update_ip_catalog
#ipx::check_integrity -quiet [ipx::current_core]
#ipx::archive_core {c:\Users\WangFule\Documents\Wav_Play\iprepo\dsm_order6\ipcfg\user.com_user_dsm_order6_1.0.zip} [ipx::current_core]
#ipx::unload_core component_4

close_project -delete
cd ../../../scripts/

exit