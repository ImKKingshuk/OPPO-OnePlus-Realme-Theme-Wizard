#!/bin/bash


ADB="adb"
THEME_STORE_PKG="com.heytap.themestore"
NEARME_THEME_STORE_PKG="com.nearme.themestore"


check_and_convert_trial_status() {
  local setting_name="$1"
  local display_name="$2"
  local uuid_setting="$3"

  adb shell settings get system "$setting_name" >tempfile.tmp
  local status=$(<tempfile.tmp)

  if [ "$status" -ne 0 ]; then
    echo "$display_name Status: Trial"
    adb shell settings put system "$uuid_setting" -1
    adb shell settings put secure "$uuid_setting" -1
    adb shell settings put system "$setting_name" 0
    adb shell settings put secure "$setting_name" 0
    echo "Successfully converted to permanent."
  else
    echo "$display_name Status: Permanent"
  fi
}


main() {
  echo "******************************************"
  echo "*    OPPO/OnePlus/Realme Theme Wizard    *"
  echo "*      ----------------------------      *"
  echo "*                        by @ImKKingshuk *"
  echo "* Github- https://github.com/ImKKingshuk *"
  echo "******************************************"
  echo


  pkill -f "$ADB"


  $ADB start-server


  if [ $? -ne 0 ]; then
    echo "ERROR - adb not found. Check if adb is in the PATH."
    exit 1
  fi


  device=$(adb reconnect | tee tempfile.tmp | tail -n 1)


  if [ "$device" = "more than one device/emulator" ]; then
    echo "ERROR - More than one Android device detected. Disconnect them or turn off USB debugging."
    rm -f tempfile.tmp
    exit 1
  fi


  if [ "$device" = "no devices/emulators found" ]; then
    echo "ERROR - No Android devices are connected. Make sure you have USB debugging turned on."
    rm -f tempfile.tmp
    exit 1
  fi

  echo
  echo "Successfully connected to $device"


  $ADB shell am force-stop "$THEME_STORE_PKG"
  $ADB shell am force-stop "$NEARME_THEME_STORE_PKG"

  echo


  check_and_convert_trial_status "persist.sys.trial.theme" "Theme" "persist.sys.oppo.theme_uuid"
  check_and_convert_trial_status "persist.sys.trial.font" "Font" "persist.sys.trial.font"
  check_and_convert_trial_status "persist.sys.trial.live_wp" "Live Wallpaper" "persist.sys.trial.live_wp_uuid"

 
  rm -f tempfile.tmp
  $ADB kill-server
}


main
