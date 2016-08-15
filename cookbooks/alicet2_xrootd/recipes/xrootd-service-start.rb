#
# Cookbook Name:: alicet2_xrootd
# Recipe: default
include_recipe 'alicet2_xrootd::default'

# Init script
node.override["xrootd"]["xrootd-proxy-init-script"]["DAEMON_OPTS"]="  -l /var/log/xrootd/xrootd.log -I v4 -k hup -c XROOTD_FULL_PATH/etc/xrootd/xrootd.cf"



xrootd_vals = node["xrootd"]["xrootd-proxy-init-script"]

  xrootd_vals.each do |k,v|
      v.to_s.gsub!('XROOTD_FULL_PATH', node["xrootd"]["installdir"])
      v.to_s.gsub!('XROOTD_CORE_FILE_PATH', node["xrootd"]["installdir"])
  end
  # Hackishly replace the array additional_pre_exec_commands
  xrootd_vals['additional_pre_exec_commands'].each do |v|
      v.to_s.gsub!('XROOTD_FULL_PATH', node["xrootd"]["installdir"])
      v.to_s.gsub!('XROOTD_CORE_FILE_PATH', node["xrootd"]["installdir"])
  end

  template "xrootd" do
    source "init-script.erb"
    cookbook "alicet2_init-script"
    path "/etc/init.d/xrootd"
    mode "755"
    owner "root"
    group "root"
    variables({:values => xrootd_vals})
  #  notifies :restart, "service[xrootd]", :delayed
  end


node.override["xrootd"]["xrootd-proxy-init-script"]["DAEMON_OPTS"]="-I v4 -l /var/log/xrootd/cmsd.log  -c #{node["xrootd"]["installdir"]}/etc/xrootd/xrootd.cf"

node.override["xrootd"]["xrootd-proxy-init-script"]["DAEMON"]="#{node["xrootd"]["installdir"]}/bin/cmsd"
node.override["xrootd"]["xrootd-proxy-init-script"]["NAME"]="cmsd"
node.override["xrootd"]["xrootd-proxy-init-script"]['PIDFILE'] = '/run/xrootd/cmsd.pid'
node.override["xrootd"]["xrootd-proxy-init-script"]['PIDDIR'] = '/run/xrootd/'


cmsd_vals=node["xrootd"]["xrootd-proxy-init-script"]
  template "cmsd" do
    source "init-script.erb"
    cookbook "alicet2_init-script"
    path "/etc/init.d/cmsd"
    mode "755"
    owner "root"
    group "root"
    variables({:values => cmsd_vals})
  #  notifies :restart, "service[cmsd]", :delayed
  end

  # Service for init script
  service "cmsd" do
    	priority 90
	action [:enable]
  end
  service "xrootd" do
    	priority 89
	action [:enable]
  end
include_recipe 'alicet2_xrootd::fix_ownership'
