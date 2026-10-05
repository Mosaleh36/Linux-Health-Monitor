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

# Disk monitoring

echo -e "\n------------ DISK ----------------------"

echo "Filesystem      : /"

total_disk=$(df -h / | tail -n 1 | awk '{print $2}')

if [[ "$total_disk" == *"G"* ]] 
then
	total_disk=$(df -h / | tail -n 1 | awk '{print $2}' | tr -d "G")
	echo "Total           : $total_disk GB"
elif [[ "$total_disk" == *"M"* ]]
then
	total_disk=$(df -h / | tail -n 1 | awk '{print $2}' | tr -d "M")
	echo "Total           : $total_disk MB"
elif [[	"$total_disk" == *"K"* ]]
then
	total_disk=$(df -h / | tail -n 1 | awk '{print $2}' | tr -d "K")
	echo "Total           : $total_disk KB"
else
	echo "Total           : $total_disk"
fi

used_disk=$(df -h / | tail -n 1 | awk '{print $3}')

if [[ "$used_disk" == *"G"* ]]
then
	used_disk=$(df -h / | tail -n 1 | awk '{print $3}' | tr -d "G")
	echo "Used            : $used_disk GB"
elif [[ "$used_disk" == *"M"* ]]
then    
        used_disk=$(df -h / | tail -n 1 | awk '{print $3}' | tr -d "M")
        echo "Used            : $used_disk MB"
elif [[ "$used_disk" == *"K"* ]]
then
        used_disk=$(df -h / | tail -n 1 | awk '{print $3}' | tr -d "K")
        echo "Used            : $used_disk KB"
else
	echo "Used            : $used_disk "

fi

free_disk=$(df -h / | tail -n 1 | awk '{print $4}')

if [[ "$free_disk" == *"G"* ]]
then
	free_disk=$(df -h / | tail -n 1 | awk '{print $4}' | tr -d "G")
	echo "Available       : $free_disk GB"
elif [[ "$free_disk" == *"M"* ]]
then    
        free_disk=$(df -h / | tail -n 1 | awk '{print $4}' | tr -d "M")
        echo "Available       : $free_disk MB"
elif [[ "$free_disk" == *"K"* ]]
then
        free_disk=$(df -h / | tail -n 1 | awk '{print $4}' | tr -d "K")
        echo "Available       : $free_disk KB"
else
	echo "Available       : $free_disk "
fi

disk_usage=$(df -h / | tail -n 1 | awk '{print $5}' | tr -d "%")

echo "Usage           : $disk_usage %"

if [[ "$disk_usage" -ge 90 ]]
then
	echo "CRITICAL: Disk usage is extremely high"
elif [[ "$disk_usage" -ge 75 ]] 
then
	echo "WARNING: Disk usage is getting high"
else
	echo "OK: Disk usage is within safe limits"
fi

# 		Add top processes 

echo -e "\n------------ PROCESSES -----------------"
echo "Top Processes:"

ps -eo pid,%cpu,%mem,comm --sort=-%cpu |  head -n 6 | grep -v "ps"

#		Add Logged In users

logged_in=$(who | awk '{print $1}')

echo -e "\n------------ USERS ---------------------"
echo -e "Logged-in users:\n$logged_in"
