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
echo "CPU Usage       : $cpu_usage"
