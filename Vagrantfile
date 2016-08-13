Vagrant.configure("2") do |config|


  allserver ={
    "xrootd":{
      "installdir":"/opt/xrootd",
      "XRDDEBUG":"",
      "XRDMAXFD":"65000",
      "XRDBASEDIR":"/var/log/xrootd",
      "LOCALROOT":"/tmp",
      "OSSCACHE":"/",
      'xrootd-proxy-init-script' => {
        'NAME' => 'xrootd',
        'Required-Start' => '$remote_fs $network',
        'Required-Stop' => '$remote_fs $network',
        'Default-Start' => '2 3 4 5',
        'Default-Stop' => '0 1 6',
        'Short-Description' => 'Starts xrootd-proxy (forward proxy)',
        'CMDLINE_SEARCH_POSITION' => '1',
        'PIDFILE' => '/run/xrootd/xrootd.pid',
        'PIDDIR' => '/run/xrootd',
        'DAEMON' => 'XROOTD_FULL_PATH/bin/xrootd',
        'DAEMON_OPTS' => '-l /var/log/xrootd/xrootd.log -I v4 -c XROOTD_FULL_PATH/etc/xrootd/proxy/xrootd.cf',
        'USER' => 'jessie',
        'GROUP' => 'jessie',
        'PTH' => '',
        'LLP' => 'XROOTD_FULL_PATH/lib:$LD_LIBRARY_PATH',
        '_STOP_COMMAND' => 'start-stop-daemon --stop --quiet --oknodo --pidfile $PIDFILE',
        'STOP_COMMAND' => 'kill $(cat $PIDFILE)',
        'DELAY_BETWEEN_START_AND_CHECK' => 10,
        'DELAY_BETWEEN_STOP_AND_CHECK' => 5,
        'additional_pre_exec_commands' => [
          'cd XROOTD_CORE_FILE_PATH',
          'ulimit -SHn 65000'
        ]
    }
  },
    "t2":{
      "redirector-hostname":"lxalird.vagrant.test",
      "SERVERONREDIRECTOR":"NO"
    },
    "users":{
      "storage-user":"jessie"
    },
    "dns":{
    "nameserver":"192.168.50.100 ",
      "a-records" => [
        "192.168.50.31	lxaliproxyrd	lxaliproxyrd.vagrant.test",
        "192.168.50.31	lxaliproxyrd1	lxaliproxyrd1.vagrant.test",
        "192.168.50.32	lxaliproxyrd	lxaliproxyrd.vagrant.test",
        "192.168.50.32	lxaliproxyrd2	lxaliproxyrd2.vagrant.test",
	"192.168.50.2	lxalird		lxalird.vagrant.test",      
	"192.168.50.3	lxalise		lxalise.vagrant.test"

],
      "ptr-records" => [
        "32.50.168.192.in-addr.arpa,lxaliproxyrd2.vagrant.test",
        "31.50.168.192.in-addr.arpa,lxaliproxyrd1.vagrant.test",
	"2.50.168.192.in-addr.arpa,lxalird.vagrant.test",      
	"3.50.168.192.in-addr.arpa,lxalise.vagrant.test"      
	]
    }
  }
  
config.vm.define "lxalidns" do |lxalidns|
    lxalidns.vm.box = "debian/contrib-jessie64"
    lxalidns.vm.hostname ="lxalidns.vagrant.test"
   lxalidns.vm.network "private_network", ip: "192.168.50.100"
    
lxalidns.vm.provision "chef_solo" do |chef|
      chef.add_recipe "alicet2_dns"
    chef.json.merge!(allserver)
    end
  end

  config.vm.define "lxalird" do |lxalird|
    lxalird.vm.box = "debian/contrib-jessie64"
    lxalird.vm.hostname = "lxalird.vagrant.test"
    lxalird.vm.network "private_network", ip:"192.168.50.2"

    lxalird.vm.provision "chef_solo" do |chef|
      chef.add_recipe "alicet2_xrootd::redirector"
    chef.json.merge!(allserver)
    end
  end
  
  config.vm.define "lxalise" do |lxalise|
    lxalise.vm.box = "debian/contrib-jessie64"
    lxalise.vm.hostname = "lxalise.vagrant.test"
    lxalise.vm.network "private_network", ip:"192.168.50.3"

    lxalise.vm.provision "chef_solo" do |chef|
      chef.add_recipe "alicet2_xrootd::dataserver"
      chef.json.merge!(allserver)
    end
  end
  
  config.vm.define "lxalic" do |lxalic|
    lxalic.vm.box = "debian/contrib-jessie64"
    lxalic.vm.hostname = "lxalic.vagrant.test"
    lxalic.vm.network "private_network", ip:"192.168.50.4"

    lxalic.vm.provision "chef_solo" do |chef|
      chef.add_recipe "alicet2_xrootd::default"
      chef.add_recipe "alicet2_xrootd::fix_ownership"

    chef.json.merge!(allserver)
    end
  end







	config.vm.define "compiler" do |compiler|
		compiler.vm.box = "debian/contrib-jessie64"
    		compiler.vm.network "private_network", type:"dhcp"
		compiler.vm.provision "chef_solo" do |chef|
      			chef.add_recipe "development_env"
    			chef.json.merge!(allserver)
    		end
  end

end
