#!/bin/ash

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "${SCRIPT_DIR}/common_functions.sh"

REQUIRED_HARDWARE="OpenWrt One"

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
