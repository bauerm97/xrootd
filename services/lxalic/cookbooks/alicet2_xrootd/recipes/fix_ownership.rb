#
# Cookbook Name:: alicet2_xrootd
# Recipe: default
user='jessie'
group='jessie'

# Fix ownerships: basedir
execute "fix-ownerships-installdir" do
  command "chown -R #{user}:#{group} " + node["xrootd"]["installdir"]
end
execute "fix-permissions" do
  command "chmod 777   " + node["xrootd"]["installdir"]+"/bin/*"
end

execute "fix-permissions" do
  command "chmod 755   /opt"
end
execute "fix-ownerships-basedir" do
  command "chown -R #{user}:#{group} " +"/opt/xrootd"
end
execute "fix-permissions" do
  command "chmod -R 777   " + node["xrootd"]["installdir"]
end
execute "fix-ownerships-basedir" do
  command "chown -R #{user}:#{group} " +"/var/log/xrootd"
end
execute "fix-ownerships-basedir" do
  command "chown -R #{user}:#{group} " +"/run/xrootd"
end
