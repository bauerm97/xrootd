#
# Cookbook Name:: alicet2_xrootd
# Recipe: default
#

# Required packages
package "dnsmasq" do
  action :install
end
service "dnsmasq" do
	action [:enable,:start]
end
#package "resolvconf" do
#  action :install
#end
package "build-essential" do
  action :install
end
package "vim" do
  action :install
end

package "cmake" do
  action :install
end

package "libxml2-dev" do
  action :install
end

package "libcurl4-openssl-dev" do
  action :install
end
#login defs needs to support CREATE_HOME YES, to let chef user add a home directory
cookbook_file "/etc/login.defs"  do
  source 'login.defs'
  action :create
end

#create the "jessie" user 
group 'jessie' do
  gid 456
  action :create
end

group='jessie'

user 'jessie'do
  uid 123
  gid 456
  supports :manage_home =>true
  action :create
end  
user='jessie'
#put all xrootd files where they should belong

#add dnsmasq entry that all vagrant.test questions go to our nameserver

#file '/etc/resolvconf/resolv.conf.d/base' do
file '/etc/resolv.conf' do
#domain vagrant.test
  content"
  nameserver #{node["dns"]["nameserver"] }
  nameserver 8.8.8.8 
"
end


file '/etc/dnsmasq.conf' do
  content"server=/vagrant.test/#{node["dns"]["nameserver"]}
"
    notifies :restart, "service[dnsmasq]"
end

#execute "reload resolvconf" do
#  command "resolvconf -u"
#end
remote_directory '/opt/xrootd' do
  source 'xrootd-contrib-jessie' 
  recursive true
end
directory '/var/log/xrootd' do
  action :create
end
directory '/run/xrootd' do
  mode "744"
  action :create
	owner user
end
directory"/opt"do
	mode "744"
	action :create
	owner user
end
directory"#{node["xrootd"]["installdir"]}"do
	mode "744"
	action :create
	owner user
end
directory"#{node["xrootd"]["installdir"]}/etc"do
	mode "744"
	action :create
	owner user
end
directory"#{node["xrootd"]["installdir"]}/etc/xrootd"do
	mode "744"
	action :create
	owner user
end
directory"#{node["xrootd"]["installdir"]}/etc/xrootd/manager"do
	mode "744"
	action :create
	owner user
end
directory"#{node["xrootd"]["installdir"]}/etc/xrootd/server"do
	mode "744"
	action :create
	owner user
end
directory"#{node["xrootd"]["installdir"]}/etc/xrootd/proxy"do
	mode "744"
	action :create
	owner user
end


  template "system.cnf"do
    source "system.cnf.erb"
    path node["xrootd"]["installdir"]+"/etc/xrootd/system.cnf"
    mode "644"
    owner user
    group group
  end
  
template "bash_profile" do
  source "bash_profile.erb"
  path "/home/"+user+"/.bash_profile"
  mode "644"
  owner user
  group group
end


template "bash_profile" do
  source "bash_profile.erb"
  path "/home/vagrant/.login_xrootd"
  mode "644"
  owner "vagrant"
  group "vagrant"
end
user 'vagrant'do
gid'jessie'
end
