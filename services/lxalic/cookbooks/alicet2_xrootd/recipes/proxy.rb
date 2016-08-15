#
# Cookbook Name:: alicet2_xrootd
# Recipe: proxy.rb
#
include_recipe 'alicet2_xrootd::default'
  template "xrootd-proxy.cf"do
    source "xrootd-proxy.cf.erb"
    path node["xrootd"]["installdir"]+"/etc/xrootd/proxy/xrootd.cf"
    mode "644"
    owner user
    group group
  end
  # Init script
  init_script_values = node["xrootd"]["xrootd-proxy-init-script"]
  init_script_values.each do |k,v|
      v.to_s.gsub!('XROOTD_FULL_PATH', node["xrootd"]["installdir"])
      v.to_s.gsub!('XROOTD_CORE_FILE_PATH', node["xrootd"]["installdir"])
  end
  # Hackishly replace the array additional_pre_exec_commands
  init_script_values['additional_pre_exec_commands'].each do |v|
      v.to_s.gsub!('XROOTD_FULL_PATH', node["xrootd"]["installdir"])
      v.to_s.gsub!('XROOTD_CORE_FILE_PATH', node["xrootd"]["installdir"])
  end


  template "xrootd-proxy-init" do
    source "init-script.erb"
    cookbook "alicet2_init-script"
    path "/etc/init.d/xrootd-proxy"
    mode "755"
    owner "root"
    group "root"
    variables({:values => init_script_values})
    notifies :restart, "service[xrootd-proxy]", :delayed
  end

  # Service for init script
  service "xrootd-proxy" do
    action [:enable, :start]
