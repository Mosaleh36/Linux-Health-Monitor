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

echo -e "\n------------ CPU -----------------------"

get_cpu_usage()
{
	if grep -qi "microsoft" /proc/version;
	then
		win_cpu=$(powershell.exe -NoProfile -Command "(Get-CimInstance Win32_Processor | Measure-Object -Property LoadPercentage -Average).Average" 2>/dev/null | tr -d '\r' | cut -d'.' -f1)
		if ! [[ "$win_cpu" =~ ^[0-9]+$ ]];
		then
			echo "Failed to read CPU usage " >&2
			return 1
		fi
		echo "$win_cpu"
		return 0
	else
	read -r _ user nice system idle iowait irq softirq steal _ < /proc/stat 
	total1=$((user + nice + system + idle + iowait+ irq + softirq + steal))
	idle1=$(( idle + iowait))
	
	sleep 1

	read -r _ user nice system idle iowait irq softirq steal _ < /proc/stat
        total2=$((user + nice + system + idle + iowait+ irq + softirq + steal))
        idle2=$(( idle + iowait))

	total_diff=$((total2 - total1))
	idle_diff=$((idle2 - idle1))
	
	if (( total_diff <= 0 ))
	then
		echo "Failed to read CPU usage"
		return 1
	fi

	cpu_usage=$(( (total_diff - idle_diff) * 100 / total_diff ))
	echo "$cpu_usage"
	fi
}

cpu_usage=""
cpu_read_failed=0
if cpu_usage=$(get_cpu_usage) && [[ "$cpu_usage" =~ ^[0-9]+$ ]];
then	
	echo "CPU Usage       : $cpu_usage%"
else
	cpu_usage=""
	cpu_read_failed=1

	echo "CPU Usage       : N/A" 
	echo "WARNING: CPU usage could not be measured" >&2
fi

#		Memory Status

total_ram=$(free | grep -n "Mem" | awk '{printf "%.2f", $2 / 1000000}')
used_ram=$(free | grep -n "Mem" | awk '{printf "%.2f", $3 / 1000000}')
available_ram=$(free | grep -n "Mem" | awk '{printf "%.2f", $7 / 1000000 }')
ram_usage=$(free | grep -n "Mem" | awk '{printf "%d", ($3/$2) * 100}')
	echo -e "\n------------ MEMORY --------------------"

	echo "Total RAM       : $total_ram GB"
	echo "Used RAM        : $used_ram GB"
	echo "Free RAM        : $available_ram GB"
	echo "Memory Usage    : $ram_usage%"

#		Disk Monitoring

echo -e "\n------------ DISK ----------------------"

if grep -qi "microsoft" /proc/version; 
then
	# Query the Windows host environment for the user profile path (e.g., C:\Users\...)
   	win_profile=$(cmd.exe /c "echo %USERPROFILE%" 2>/dev/null | tr -d '\r')
   	wsl_drive="${win_profile:0:1}"
	wsl_drive="${wsl_drive,,}"
   	[ -z "$wsl_drive" ] && wsl_drive="c" # Fallback to C if unretrievable

	echo "Filesystem      : / (WSL $wsl_drive:)"
	total_disk=$(df /mnt/"$wsl_drive" -h | tail -n 1 | awk '{print $2}')
	used_disk=$(df -h /mnt/"$wsl_drive" | tail -n 1 | awk '{print $3}')
	free_disk=$(df -h /mnt/"$wsl_drive" | tail -n 1 | awk '{print $4}')
	disk_usage=$(df -h /mnt/"$wsl_drive" | tail -n 1 | awk '{print $5}' | tr -d "%")

else
	echo "Filesystem      : / "
	total_disk=$(df -h / | tail -n 1 | awk '{print $2}')
	used_disk=$(df -h / | tail -n 1 | awk '{print $3}')
	free_disk=$(df -h / | tail -n 1 | awk '{print $4}')
	disk_usage=$(df -h / | tail -n 1 | awk '{print $5}' | tr -d "%")
fi

size_unit() {
	local val="$1"
	case "$val" in 
		*G) echo "${val%G} GB" ;;
		*M) echo "${val%M} MB" ;;
		*K) echo "${val%K} KB" ;;
		*T) echo "${val%T} TB" ;;
		*) echo "$val" ;;
	esac	
}	

echo "Total           : $(size_unit "$total_disk")"
echo "Used            : $(size_unit "$used_disk")"
echo "Available       : $(size_unit "$free_disk")"
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
active_services=$(service --status-all 2>/dev/null | grep '+' | awk '{print $4}')

echo -e "Services are running: \n\n$active_services"

#		Network
my_IPV4_ip_address=$(hostname -I | awk '{print $1}')
host_name=$(hostname -s)

echo -e "\n------------ NETWORK -------------------"
echo "IP Address      : $my_IPV4_ip_address"
echo "Hostname        : $host_name"

#		Overall Status
echo -e "\n========================================"

if [[ "$cpu_read_failed" -eq 0 ]];
then
if [[ "$cpu_usage" -ge 90 || "$ram_usage" -ge 90 || "$disk_usage" -ge 90 ]];
then	
	status="CRITICAL"
	exit_code=90
elif [[ "$cpu_usage" -ge 75 || "$ram_usage" -ge 75 || "$disk_usage" -ge 75 ]];
then
	status="WARNING"
	exit_code=75
else
	status="HEALTHY"
	exit_code=0
fi

else
if [[ "$ram_usage" -ge 90 || "$disk_usage" -ge 90 ]];
then	
	status="CRITICAL"
	exit_code=90
elif [[ "$ram_usage" -ge 75 || "$disk_usage" -ge 75 ]];
then
	status="WARNING"
	exit_code=75
else
	status="HEALTHY"
	exit_code=0
fi
fi
echo "Status: $status"
echo "========================================"
exit "$exit_code"