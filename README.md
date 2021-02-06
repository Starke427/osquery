# OSquery
osquery is an operating system instrumentation framework that extends the security monitoring capabilities on Linux hosts. The tools make low-level operating system analytics and monitoring both performant and intuitive.

osquery exposes an operating system as a high-performance relational database. This allows you to write SQL queries to explore operating system data. With osquery, SQL tables represent abstract concepts such as running processes, loaded kernel modules, open network connections, browser plugins, hardware events or file hashes. By leveraging these sqlite databases, osquery is able to perform file integrity monitoring.

## Automated OSquery Installation

[osquery_setup.sh](https://raw.githubusercontent.com/Starke427/osquery/master/osquery_setup.sh) will download OSquery from and apply a security enhanced configuration file from this github. It must be run as root on either a CentOS or Ubuntu host.

```
curl -o osquery_setup.sh https://raw.githubusercontent.com/Starke427/osquery/master/osquery_setup.sh
chmod 750 osquery_setup.sh
./osquery_setup.sh

```
