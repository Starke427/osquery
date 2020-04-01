#!/bin/bash

cat << EOF

This script must be executed as root or the writing of the osquery configuration file will fail.

EOF

function aptInstall() {
export OSQUERY_KEY=1484120AC4E9F8A1A577AEEE97A80C63C9D8B80B
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys $OSQUERY_KEY
sudo add-apt-repository 'deb [arch=amd64] https://pkg.osquery.io/deb deb main'
sudo apt-get update -y
sudo apt-get install osquery -y
}

function yumInstall() {
curl -L https://pkg.osquery.io/rpm/GPG | sudo tee /etc/pki/rpm-gpg/RPM-GPG-KEY-osquery
sudo yum-config-manager --add-repo https://pkg.osquery.io/rpm/osquery-s3-rpm.repo
sudo yum-config-manager --enable osquery-s3-rpm
sudo yum install osquery -y
}

operatingSystem=$(hostnamectl | grep System | cut -d " " -f5)
if [ $operatingSystem == CentOS ]; then
  echo "Preparing YUM Installation...
  "
  yumInstall
elif [ $operatingSystem == Ubuntu ]; then
  echo "Preparing APT Installation...
  "
  aptInstall
else
  echo "Unable to identify the current operating system. Please ensure the system is either CentOS or Ubuntu."
fi

sudo cat > /etc/osquery/osquery.conf << EOF
{
"options": {
"config_plugin": "filesystem",
"logger_plugin": "syslog",
"events_expiry": "3600"
},
"schedule": {
"users": {
"query": "SELECT * from users;",
"interval": "3600",
"platform": "all",
"version": "1.4.5",
"description": "",
"value": ""
},
"listening_ports": {
"query": "SELECT uid, name, port, protocol FROM listening_ports l, processes p WHERE l.pid=p.pid;",
"interval": "300",
"platform": "all",
"version": "1.4.5",
"description": "",
"value": ""
},
"crontab": {
"query": "SELECT * from crontab;",
"interval": "300",
"platform": "all",
"version": "1.4.5",
"description": "",
"value": ""
},
"kernel_modules": {
"query": "SELECT name,size,status from kernel_modules;",
"interval": "300",
"platform": "all",
"version": "1.4.5",
"description": "",
"value": ""
},
"processes": {
"query": "SELECT pid, name, path, cmdline from processes;",
"interval": "300",
"platform": "all",
"version": "1.4.5",
"description": "",
"value": ""
},
"suid_bin": {
"query": "select * from suid_bin;",
"interval": "300",
"platform": "all",
"version": "1.4.5",
"description": "",
"value": ""
},
"outbound_connections": {
"query": "select user.username, proc.name, hash.md5, socket.pid, proc.path, proc.cmdline, socket.local_port, socket.remote_port, socket.remote_address from process_open_sockets as socket, processes as proc, users as user, hash as hash where socket.local_port not in (select port from listening_ports) and socket.local_port != 0 and socket.pid = proc.pid and user.uid = proc.uid and hash.path = proc.path;",
"interval": "300",
"platform": "all",
"version": "1.4.5",
"description": "",
"value": ""
},
"file_events": {
"query": "SELECT * from file_events;",
"interval": 300
}
},
"file_paths": {
    "etc": [
      "/etc/%%"
    ],
    "homes": [
      "/root/%%",
      "/home/%/%%"
    ],
    "binaries": [
		"/usr/bin/%%",
		"/usr/sbin/%%",
		"/bin/%%",
		"/sbin/%%",
		"/usr/local/bin/%%",
		"/usr/local/sbin/%%",
		"/opt/bin/%%",
		"/opt/sbin/%%"
	],
	"ssh_keys": [
		"/home/%/.ssh/authorized_keys"
	]
}
}
EOF

sudo osqueryd --daemonize --config_path /etc/osquery/osquery.conf
