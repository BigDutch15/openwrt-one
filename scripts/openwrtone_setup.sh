#!/bin/ash

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "${SCRIPT_DIR}/common_functions.sh"

REQUIRED_HARDWARE="OpenWrt One"


# Load configuration
router_name=${ROUTER_NAME:-"OpenWrt"}
router_timezone=${ROUTER_TIMEZONE:-"CST6CDT,M3.2.0,M11.1.0"}
router_timezone_name=${ROUTER_TIMEZONE_NAME:-"America/Chicago"}

# ====================================================================
# STEP 0: Validate hardware
# ====================================================================
if ! validate_hardware "$REQUIRED_HARDWARE"; then
    exit 1
fi

# ====================================================================
# STEP 1: Detect WAN interface for firewall configuration
# ====================================================================
detect_wan_interface

# ====================================================================
# STEP 2: Set system information
# ====================================================================
if ! set_hostname "$router_name"; then
    exit 1
fi

if ! set_timezone "$router_timezone_name" "$router_timezone"; then
    exit 1
fi

# ====================================================================
# STEP 3: Apply configuration changes
# ====================================================================
if ! restart_services; then
    exit 1
fi