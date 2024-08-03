#!/bin/bash

ADB="adb"
THEME_STORE_PKG="com.heytap.themestore"
NEARME_THEME_STORE_PKG="com.nearme.themestore"

print_banner() {
    local banner=(
        "******************************************"
        "*    OPPO/OnePlus/Realme Theme Wizard    *"
        "*           Theme Patching Tool          *"
        "*                  v1.3.1                *"
        "*      ----------------------------      *"
        "*                        by @ImKKingshuk *"
        "* Github- https://github.com/ImKKingshuk *"
        "******************************************"
    )
    local width=$(tput cols)
    for line in "${banner[@]}"; do
        printf "%*s\n" $(((${#line} + width) / 2)) "$line"
    done
    echo
}



check_for_updates() {
    local current_version=$(cat version.txt)
    local latest_version=$(curl -sSL "https://raw.githubusercontent.com/ImKKingshuk/OPPO-OnePlus-Realme-Theme-Wizard/main/version.txt")

    if [ "$latest_version" != "$current_version" ]; then
        echo "A new version ($latest_version) is available. Updating Tool... Please Wait..."
        update_tool
    else
        echo "You are using the latest version ($current_version)."
    fi
}

update_tool() {
    local repo_url="https://raw.githubusercontent.com/ImKKingshuk/OPPO-OnePlus-Realme-Theme-Wizard/main"
    curl -sSL "$repo_url/ThemeWizard.sh" -o ThemeWizard.sh
    curl -sSL "$repo_url/version.txt" -o version.txt

    echo "Tool has been updated to the latest version."
    exec bash ThemeWizard.sh
}


check_and_convert_trial_status() {
    local setting_name="$1"
    local display_name="$2"
    local uuid_setting="$3"

    local status=$($ADB shell settings get system "$setting_name" 2>/dev/null)

    if [ "$status" -ne 0 ]; then
        echo "$display_name Status: Trial"
        $ADB shell settings put system "$uuid_setting" -1
        $ADB shell settings put secure "$uuid_setting" -1
        $ADB shell settings put system "$setting_name" 0
        $ADB shell settings put secure "$setting_name" 0
        echo "Successfully converted to permanent."
    else
        echo "$display_name Status: Permanent"
    fi
}

main() {
    print_banner

    pkill -f "$ADB"

    $ADB start-server
    if [ $? -ne 0 ]; then
        echo "ERROR - adb not found. Check if adb is in the PATH."
        exit 1
    fi

    local device=$($ADB reconnect 2>&1 | tail -n 1)

    if [[ "$device" == *"more than one device/emulator"* ]]; then
        echo "ERROR - More than one Android device detected. Disconnect them or turn off USB debugging."
        exit 1
    fi

    if [[ "$device" == *"no devices/emulators found"* ]]; then
        echo "ERROR - No Android devices are connected. Make sure you have USB debugging turned on."
        exit 1
    fi

    echo "Successfully connected to $device"

    $ADB shell am force-stop "$THEME_STORE_PKG"
    $ADB shell am force-stop "$NEARME_THEME_STORE_PKG"

    check_and_convert_trial_status "persist.sys.trial.theme" "Theme" "persist.sys.oppo.theme_uuid"
    check_and_convert_trial_status "persist.sys.trial.font" "Font" "persist.sys.trial.font"
    check_and_convert_trial_status "persist.sys.trial.live_wp" "Live Wallpaper" "persist.sys.trial.live_wp_uuid"

    $ADB kill-server
}

main
