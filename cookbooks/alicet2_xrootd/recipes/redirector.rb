#
# Cookbook Name:: alicet2_xrootd
# Recipe: default
  
template "manager.xrootd.cf."do
    source "manager-xrootd.cf.erb"
    path node["xrootd"]["installdir"]+"/etc/xrootd/xrootd.cf"
    mode "644"
    owner user
    group group
end



