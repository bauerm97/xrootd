#
# Cookbook Name:: alicet2_xrootd
# Recipe: default
#

# Required packages
package "dnsmasq" do
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
package "vim" do
  action :install
end
package "dnsutils" do
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
log '1' do #log my node element
  message node.flatten.to_s
end
arecords=""
precords=""
node["dns"]["a-records"].each{|x| arecords << x.to_s << "\n" }
node["dns"]["ptr-records"].each{|x| precords << "ptr-record=" << x << "\n" }
file '/etc/hosts.vagrant.test.dnsmasq' do
        content arecords 
notifies :restart, "service[dnsmasq]", :delayed
end
file '/etc/dnsmasq.d/hosts.vagrant.test.dnsmasq.conf' do
  content"addn-hosts=/etc/hosts.vagrant.test.dnsmasq\n"+precords
end



service "dnsmasq" do
action [:enable,:start]
end
