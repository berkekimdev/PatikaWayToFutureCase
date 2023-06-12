#!/bin/bash

check_disk_usage() {
	local disk_usage=$(df -h / | awk 'NR==2 {print $5}' | tr -d '%')
	if [ $disk_usage -gt 90 ]; then
		echo "Uyarı: Root diskinin kullanım oranı $disk_usage%'ı geçti!"
	else
		echo "Root diski kullanım oranı şu anda $disk_usage%, %90'ı geçmedi."
	fi
}

check_disk_usage
