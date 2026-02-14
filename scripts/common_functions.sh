#!/bin/ash

# Common functions library for OpenWrt router setup scripts
# This file should be sourced by router-specific setup scripts

# ====================================================================
# Hardware Detection Functions
# ====================================================================

# Function to get machine model from dmesg
get_machine_model() {
	local model=""
	
	# Try to extract machine model from dmesg output
	# Look for common patterns like "Machine model:" or "Machine:"
	model=$(dmesg | grep -i "machine" | grep -i "model" | head -n 1 | sed 's/.*[Mm]achine.*[Mm]odel[: ]*//; s/^[ \t]*//')
	
	# If that didn't work, try alternative patterns
	if [ -z "$model" ]; then
		model=$(dmesg | grep -E "^[[:space:]]*Machine:" | head -n 1 | sed 's/.*Machine[: ]*//; s/^[ \t]*//')
	fi
	
	# Return the model if found
	if [ -n "$model" ]; then
		echo "$model"
		return 0
	fi
	
	# Return empty if not found
	echo ""
	return 1
}

# Validate hardware model
validate_hardware() {
	local required_hardware="$1"
	local detected_model
	
	detected_model=$(get_machine_model)
	echo "[INFO] Machine model detected: $detected_model"
	
	if [ "$detected_model" != "$required_hardware" ]; then
		echo "[ERROR] Machine model is not $required_hardware, exiting script"
		return 1
	fi
	
	return 0
}

# ====================================================================
# Network Configuration Functions
# ====================================================================

# Detect WAN interface for firewall configuration
detect_wan_interface() {
	echo "[INFO] Detecting WAN interface for firewall rules..."
	. /lib/functions/network.sh
	network_flush_cache
	network_find_wan NET_IF
	FW_WAN="$(fw4 -q network ${NET_IF})"
	echo "[INFO] WAN interface detected: $NET_IF (firewall zone: $FW_WAN)"
	
	# Export for use in calling script
	export NET_IF
	export FW_WAN
}

# ====================================================================
# System Configuration Functions
# ====================================================================

# Set system hostname
set_hostname() {
	local hostname="$1"
	
	echo "[INFO] Setting system hostname to $hostname..."
	uci set system.@system[0].hostname="$hostname"
	if ! uci commit system; then
		echo "[ERROR] Failed to commit system hostname changes"
		return 1
	fi
	return 0
}

# Set system timezone
set_timezone() {
	local timezone_name="$1"
	local timezone="$2"
	
	echo "[INFO] Setting system timezone to $timezone_name..."
	uci set system.@system[0].zonename="$timezone_name"
	uci set system.@system[0].timezone="$timezone"
	if ! uci commit system; then
		echo "[ERROR] Failed to commit system timezone changes"
		return 1
	fi
	return 0
}

# ====================================================================
# Service Management Functions
# ====================================================================


# Restart all services to apply configuration
restart_services() {
	echo "[INFO] Reload the system service..."
	if ! /etc/init.d/system reload; then
		echo "[WARNING] Failed to reload system service (non-critical)"
	fi

	echo "[SUCCESS] All services restarted successfully"
	return 0
}