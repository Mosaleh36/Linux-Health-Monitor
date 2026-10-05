#!/bin/bash


# Header Format
/usr/bin/echo -e "========================================\n        LINUX SERVER HEALTH REPORT"
/usr/bin/echo -e "========================================\n"

#		System Information

echo "Hostname        : $(/usr/bin/hostname)"
echo "Date            : $(/usr/bin/date +"%Y-%m-%d %H:%M:%S")"
echo "Uptime          : $(/usr/bin/uptime -p)"
echo "OS              : $(/usr/bin/grep 'PRETTY_NAME=' /etc/os-release | cut -d '=' -f2 | tr -d '""')"


#		CPU Usage

cpu_usage=$(awk '/cpu /{usage=($2+$4)*100/($2+$4+$5)} END {printf "%.1f", usage}' /proc/stat)
echo -e "\n------------ CPU -----------------------"
echo "CPU Usage       : $cpu_usage%"


#		Memory Status

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
	total_ram=$(free -h | grep -n "Mem" | awk '{print $2}' | tr -d "Mi")
	echo "Total RAM       : $total_ram MB"
fi

if [[ "$used_ram" == *"Gi"* ]]
then
	used_ram=$(free -h | grep -n "Mem" | awk '{print $3}' | tr -d "Gi")
	echo "Used RAM        : $used_ram GB"
else
	used_ram=$(free -h | grep -n "Mem" | awk '{print $3}' | tr -d "Mi" )
	 echo "Used RAM        : $used_ram MB"
fi

if [[ "$available_ram" == *"Gi"* ]] 
then
	available_ram=$(free -h | grep -n "Mem" | awk '{print $7}' | tr -d "Gi")
	echo "Free RAM        : $available_ram GB"
elif [[ "$available_ram" == *"Mi"* ]]
then
	available_ram=$(free -h | grep -n "Mem" | awk '{print $7}' | tr -d "Mi")
	echo "Free RAM        : $available_ram MB"
else
	available_ram=$(free -h | grep -n "Mem" | awk '{print $7}')
	echo "Free RAM        : $available_ram"
fi

used_ram=$(free -h | grep -n "Mem" | awk '{print $3}')

if [[ "$used_ram" == *"Mi"* ]]
then
ram_usage=$(free -h | grep -n "Mem" | awk '{printf "%d", $3/1000/$2 * 100}')
fi
echo "Memory Usage    : $ram_usage%"

#		Disk Monitoring

echo -e "\n------------ DISK ----------------------"

echo "Filesystem      : /"

if grep -qi "microsoft" /proc/version; 
then
total_disk=$(df /mnt/c -h | tail -n 1 | awk '{print $2}')
used_disk=$(df -h /mnt/c | tail -n 1 | awk '{print $3}')
free_disk=$(df -h /mnt/c | tail -n 1 | awk '{print $4}')
disk_usage=$(df -h /mnt/c | tail -n 1 | awk '{print $5}' | tr -d "%")

else
total_disk=$(df -h / | tail -n 1 | awk '{print $2}')
used_disk=$(df -h / | tail -n 1 | awk '{print $3}')
free_disk=$(df -h / | tail -n 1 | awk '{print $4}')
disk_usage=$(df -h / | tail -n 1 | awk '{print $5}' | tr -d "%")
fi


if [[ "$total_disk" == *"G"* ]] 
then
	clean_total=$(echo "$total_disk" | tr -d "G")
	echo "Total           : $clean_total GB"
elif [[ "$total_disk" == *"M"* ]]
then
	clean_total=$(echo "$total_disk" | tr -d "M")
	echo "Total           : $clean_total MB"
elif [[	"$total_disk" == *"K"* ]]
then
	clean_total=$(echo "$total_disk" | tr -d "K")
	echo "Total           : $clean_total KB"
else
	echo "Total           : $total_disk"
fi

if [[ "$used_disk" == *"G"* ]]
then
	clean_used=$(echo "$used_disk" | tr -d "G")
	echo "Used            : $clean_used GB"
elif [[ "$used_disk" == *"M"* ]]
then    
        clean_used=$(echo "$used_disk" | tr -d "M")
        echo "Used            : $clean_used MB"
elif [[ "$used_disk" == *"K"* ]]
then
        clean_used=$(echo "$used_disk" | tr -d "K")
        echo "Used            : $clean_used KB"
else
	echo "Used            : $used_disk "

fi
#free_disk=$(df -h / | tail -n 1 | awk '{print $4}')

if [[ "$free_disk" == *"G"* ]]
then
	clean_free=$(echo "$free_disk" | tr -d "G")
	echo "Available       : $clean_free GB"
elif [[ "$free_disk" == *"M"* ]]
then    
        clean_free=$(echo "$free_disk" | tr -d "M")
        echo "Available       : $clean_free MB"
elif [[ "$free_disk" == *"K"* ]]
then
        clean_free=$(echo "$free_disk" | tr -d "K")
        echo "Available       : $clean_free KB"
else
	echo "Available       : $free_disk "
fi

#disk_usage=$(df -h / | tail -n 1 | awk '{print $5}' | tr -d "%")

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

#		Top processes 

echo -e "\n------------ PROCESSES -----------------"
echo "Top Processes:"

ps -eo pid,%cpu,%mem,comm --sort=-%cpu |  head -n 6 | grep -v "ps"

#		Logged In users

logged_in=$(who | awk '{print $1}')

echo -e "\n------------ USERS ---------------------"
echo -e "Logged-in users:\n$logged_in"


#		Services Running

echo -e "\n------------ SERVICES ------------------"
active_services=$(service --status-all | grep '+' | awk '{print $4}')

echo -e "Services are running: \n\n$active_services"

#		Network
my_IPV4_ip_address=$(hostname -I | awk '{print $1}')
host_name=$(hostname -s)

echo -e "\n------------ NETWORK -------------------"
echo "IP Address      : $my_IPV4_ip_address"
echo "Hostname        : $host_name"

#		Overall Status
echo -e "\n========================================"

cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'.' -f1)
ram_usage=$(free | awk '/Mem:/ {printf "%d", $3/$2 * 100}')
disk_usage=$(df / | awk 'NR==2 {print $5}' | tr -d '%')

if [[ "$cpu_usage" -ge 90 || "$ram_usage" -ge 90 || "$disk_usage" -ge 90 ]];
then	
	status="CRITICAL"
elif [[ "$cpu_usage" -ge 75 || "$ram_usage" -ge 75 || "$disk_usage" -ge 75 ]];
then
	status="WARNING"
else
	status="HEALTHY"
fi
echo "Status: $status"
echo "========================================"
