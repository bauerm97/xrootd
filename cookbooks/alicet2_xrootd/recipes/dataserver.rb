#
# Cookbook Name:: alicet2_xrootd
# Recipe: default
include_recipe 'alicet2_xrootd::xrootd-service'
  
template "server-xrootd.cf"do
    source "server-xrootd.cf.erb"
    path node["xrootd"]["installdir"]+"/etc/xrootd/xrootd.cf"
    mode "644"
    owner user
    group group
end


