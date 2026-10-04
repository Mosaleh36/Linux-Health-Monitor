#!/bin/bash


# Header Format
/usr/bin/echo -e "========================================\n        LINUX SERVER HEALTH REPORT"
/usr/bin/echo -e "========================================\n"

# Sysytem information

echo "Hostname        : $(/usr/bin/hostname)"
echo "Date            : $(/usr/bin/date +"%Y-%m-%d %H:%M:%S")"
echo "Uptime          : $(/usr/bin/uptime -p)"
echo "OS              : $(/usr/bin/grep 'PRETTY_NAME=' /etc/os-release | cut -d '=' -f2 | tr -d '""')"


# Add CPU usage

cpu_usage=$(top -bn2 -d 0.5 | grep "Cpu(s)" | tail -n 1 | awk '{print 100 - $8}') 

echo -e "\n------------ CPU -----------------------"
echo "CPU Usage       : $cpu_usage%"


# Add memory status

total_ram=$(free -h | grep -n "Mem" | awk '{print $2}')
used_ram=$(free -h | grep -n "Mem" | awk '{print $3}')
available_ram=$(free -h | grep -n "Mem" | awk '{print $7}')
ram_usage=$(free -h | grep -n "Mem" | awk '{printf "%d", $3/$2 * 100}')

echo -e "\n------------ MEMORY --------------------"

if [[ "$total_ram" == *"Gi"* ]]
then
	total_ram=$(free -h | grep -n "Mem" | awk '{print $2}' | tr -d "Gi")
	echo "Total RAM       : $total_ram GB"
else
	total_ram=$(free -h | grep -n "Mem" | awk '{print $2}' | tr -d "M")
	echo "Total RAM       : $total_ram MB"
fi

if [[ "$used_ram" == *"Gi"* ]]
then
	used_ram=$(free -h | grep -n "Mem" | awk '{print $3}' | tr -d "Gi")
	echo "Used RAM        : $used_ram GB"
else
	used_ram=$(free -h | grep -n "Mem" | awk '{print $3}' | tr -d "M" )
	 echo "Used RAM        : $used_ram MB"
fi

if [[ "$available_ram" == *"Gi"* ]] 
then
	available_ram=$(free -h | grep -n "Mem" | awk '{print $7}' | tr -d "Gi")
	echo "Free RAM        : $available_ram GB"
else
	available_ram=$(free -h | grep -n "Mem" | awk '{print $7}' | tr -d "Mi")
	echo "Free RAM        : $available_ram MB"
fi

echo "Memory Usage    : $ram_usage%"


