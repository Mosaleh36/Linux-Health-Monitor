Linux Health Monitor

A lightweight Bash script that monitors Linux system health and identifies potential resource issues.

Features

System Information: Hostname, OS, and uptime.

Resource Monitoring: CPU, RAM, and disk usage.

Process Monitoring: Top resource-consuming processes.

System Information: Logged-in users, services, and network details.

Health Status: Reports HEALTHY, WARNING, or CRITICAL.

Requirements

Ubuntu Linux or WSL

Bash and standard Linux utilities

Needs (ps, free, df) command installation

Usage

chmod +x healthcheck.sh
./healthcheck.sh

To validate Bash syntax:

bash -n healthcheck.sh

Purpose

Built to practice Bash scripting, Linux system administration, and basic system monitoring as part of my DevOps learning journey.

Platform: Ubuntu Linux / WSL
Language: Bash

## Screenshot

![Linux Health Monitor output](Linux-health-screenshot.jpeg)
