#!/bin/bash

# Sample shell script that provides host (and services) monitoring with ApMon.
#
# 2007-06-07
# Catalin.Cirstoiu@cern.ch
#
# Rewritten the logic behind pidfiles and "stay alive" mechanism
# May 2010
# Fabrizio Furano



usage(){
	cat <<EOM
usage: servMon.sh [[-f|-k] -p pidfile] hostGroup [serv1Name pid1] ...
     -p pidfile   - put ApMon's PID in this file and run in background. If
                    pidfile already contains a running process, just exit.
	-f        - kill previous background-running ApMon with the same pidfile
	            and will start a new one with the new parameters
	-k        - just kill previous background-running ApMon
	hostGroup - base name for the host monitoring
	servXName - name of the X'th service
	pidX      - pid of the X'th service
EOM
	exit 1
}

# Get the machine's hostname
host=`hostname -f`

if [ $# -eq 0 ] ; then
  usage
fi

hostGroup=
newline="
"
while [ $# -gt 0 ] ; do
	case "$1" in
		-f)
			force=1   # Set the force flag
			;;
		-k)
			force=1	  
			justKill=1
			;;
		-p)
			pidfile=$2 # Set the pidfile
			shift
			;;
		-*)
			echo -e "Invalid parameter '$1'\n"
			usage
			;;
		*)
			if [ -z "$hostGroup" ] ; then
				hostGroup=$1 # First bareword is the host group, for host monitoring
			else
				if [ -n "$2" ] ; then
					srvMonCmds="${srvMonCmds}${newline}\$apm->addJobToMonitor($2, '', '${1}_Services', '$host');"
					shift
				else
					echo -e "Service '$1' needs pid number!\n"
  					usage
				fi
			fi
	esac
	shift
done

KillAllApMon() {

    for nm in `find $pidfile* 2>/dev/null` ; do
	pid=`cat $nm`
	echo "Killing previous ApMon instance with pid $pid ..."
	kill -9 $pid 2>/dev/null
	rm $nm
    done


}



# If pidfile was given, check the supposedly running processes
#  pidfile is the prefix which is given to the pidfiles
#
# If they are too many, kill them all (and remove the pidfiles)
# If 'force' kill them all (and remove the pidfiles)

# If pidfile was given, check if there is a running process with that pid
if [ -n "$pidfile" ] ; then
    nproc=`find $pidfile* 2>/dev/null | wc -l`
    if [ "$nproc" -gt 1 ] ; then
	echo "There seem to be too many ApMon processes running. Killing them all."
	KillAllApMon
	nproc=0;
    fi
    if [ -n "$force" ] ; then
	echo "Requested killing previous ApMon instances."
	KillAllApMon
    else
	if [ "$nproc" -gt 0 ] ; then
	    exit 0;
	fi

    fi

fi

if [ -n "$justKill" ] ; then
	exit 0;
fi

#Set the destination for the monitoring information
#destination="\"http://monalisa2.cern.ch/~catac/apmon/destinations.conf\""
#destination="['pcardaab.cern.ch:8884']"
#destination="{'pcardaab.cern.ch' => {loglevel => 'NOTICE'}}"
MONALISA_HOST=${MONALISA_HOST:-"localhost"}
APMON_DEBUG_LEVEL=${APMON_DEBUG_LEVEL:-"WARNING"}
destination=${APMON_CONFIG:-"['$MONALISA_HOST']"}


nodename4space="$SE_NAME""_server_xrootd_Services"
port="$XRDSERVERPORT"
if [ "x$host" = "x$MANAGERHOST" ] ; then
  nodename4space="$SE_NAME""_manager_xrootd_Services"
  port="$XRDMANAGERPORT"
fi


#Finally, run the perl interpreter with a small program that sends all these parameters
exe="use strict;
use warnings;
use ApMon;
my \$apm = new ApMon(0);
\$apm->setLogLevel('$APMON_DEBUG_LEVEL');
\$apm->setDestinations($destination);
\$apm->setMonitorClusterNode('${hostGroup}_SysInfo', '$host');$srvMonCmds

my \$pid = fork();

if(\$pid == 0)
{
        while(1)
	{
		open (MYFILE, \">$pidfile.\$$\");
		print MYFILE \$\$;
		close (MYFILE); 
		\$apm->sendBgMonitoring();
		my \$xrdver=\`$prefix/bin/xrd 127.0.0.1:$port query 1 /dummy | awk '{print \\\$3}' | cut -d'=' -f 2 \`;
		\$xrdver =~ tr/\"//d;
		print \$xrdver;
		\$apm->sendParameters('$nodename4space', '$host', 'xrootd_version', \$xrdver);
		my \$totsp = \`$prefix/bin/xrd 127.0.0.1:$port queryspace / | grep Total | cut -d':' -f 2 | tr -d ' ' \`;
		\$apm->sendParameters('$nodename4space', '$host', 'space_total', \$totsp);
		my \$freesp = \`$prefix/bin/xrd 127.0.0.1:$port queryspace / | grep Free | cut -d':' -f 2 | tr -d ' ' \`;
		\$apm->sendParameters('$nodename4space', '$host', 'space_free', \$freesp);
		my \$lrgst = \`$prefix/bin/xrd 127.0.0.1:$port queryspace / | grep Largest | cut -d':' -f 2 | tr -d ' ' \`;
		\$apm->sendParameters('$nodename4space', '$host', 'space_largestfreechunk', \$lrgst);
		sleep(120);
	}
}
else
{
	my \$Line;
	my \$Var;
	my \$Val;
	my %Statsdata;
	open my \$Stdout, \"$prefix/bin/mpxstats -f flat -p 1234 |\";
	while (<\$Stdout>)
	{
		undef %Statsdata;
		\$Line = \"\$_\";
		(\$Var,\$Val) = split(' ',\$Line);
		if(defined(\$Var))
		{
			\$Statsdata{\$Var} = \$Val;
		}
		\$apm->sendParameters('${hostGroup}_ApMon_Info', '$host', %Statsdata);
	}
}
"

#echo "Exe = [$exe]"

export PERL5LIB=`dirname $0`

if [ -n "$pidfile" ] ; then
	# pid file given; run in background
	#logfile="`dirname $pidfile`/`basename $pidfile .pid`.log"
        logfile="${XRDBASEDIR}/logs/`basename $pidfile .pid`.log"
	echo -e "`date` Starting ApMon in background mode...\nlogfile in: $logfile\npidfile in: $pidfile" | tee $logfile
	perl -e "$exe" </dev/null >> $logfile 2>&1 &
else
	# pid file not given; run in interactive mode
	echo -e "`date` Starting ApMon in interactive mode..."
	exec perl -e "$exe"
fi

