#!/bin/ash

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "${SCRIPT_DIR}/common_functions.sh"

REQUIRED_HARDWARE="OpenWrt One"


# Load configuration
router_name=${ROUTER_NAME:-"OpenWrt"}

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


# ====================================================================
# STEP 3: Apply configuration changes
# ====================================================================
if ! restart_services; then
    exit 1
fi