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