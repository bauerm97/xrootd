#
# Cookbook Name:: alicet2_xrootd
# Recipe: default
#

# Required packages
package "build-essential" do
  action :install
end
package "vim" do
  action :install
end

package "cmake" do
  action :install
end

package "gcc" do
  action :install
end

package "g++" do
  action :install
end
package "git" do
  action :install
end

package "libxml2-dev" do
  action :install
end
package "zlib1g-dev" do
  action :install
end

package "libcurl4-openssl-dev" do
  action :install
end

git '/home/vagrant/xrootd' do
	repository 'https://github.com/xrootd/xrootd.git'
	action :sync	
	user "vagrant"
end
directory "/home/vagrant/compile_xrootd" do
	owner 'vagrant'
	mode '0755'
	action :create
end
#execute "xrootd_comp" do
#command 
#	"cmake /home/vagrant/xrootd -DCMAKE_INSTALL_PREFIX= /home/vagrant/xrootd-install &&\ 
#	make -j2 && \
#	make install  && \
#	cp -r /home/vagrant/xrootd-install /vagrant/xrootd-install  " 
#user "vagrant#"
#end
