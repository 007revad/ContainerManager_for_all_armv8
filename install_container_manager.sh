#!/usr/bin/env bash
# shellcheck disable=SC2076
#---------------------------------------------------------------------------------------
# Install Container Manager on RS819, DS119j, DS418, DS418j, DS218, DS218play and DS118
#
# Github: https://github.com/007revad/ContainerManager_for_all_armv8
# Script verified at https://www.shellcheck.net/
#
# To run in a shell (replace /volume1/scripts/ with path to script):
# sudo -s /volume1/scripts/install_container_manager.sh
#---------------------------------------------------------------------------------------

scriptver="v1.3.8"
script=ContainerManager_for_all_armv8
#repo="007revad/ContainerManager_for_all_armv8"
#scriptname=install_container_manager


# Shell Colors
#Black='\e[0;30m'   # ${Black}
#Red='\e[0;31m'      # ${Red}
#Green='\e[0;32m'   # ${Green}
#Yellow='\e[0;33m'   # ${Yellow}
#Blue='\e[0;34m'    # ${Blue}
#Purple='\e[0;35m'  # ${Purple}
Cyan='\e[0;36m'     # ${Cyan}
#White='\e[0;37m'   # ${White}
Error='\e[41m'      # ${Error}
#Warn='\e[47;31m'   # ${Warn}
Off='\e[0m'         # ${Off}

ding(){ 
    [ "$trace" == "yes" ] && echo "${FUNCNAME[0]} called from ${FUNCNAME[1]}"
    printf \\a
}

if [[ $1 == "--trace" ]] || [[ $1 == "-t" ]]; then
    trace="yes"
fi

# Check script is running as root
if [[ $( whoami ) != "root" ]]; then
    ding
    echo -e "${Error}ERROR${Off} This script must be run as sudo or root!"
    exit 1  # Not running as root
fi

# Check script is running on a Synology NAS
if ! /usr/bin/uname -a | grep -i synology >/dev/null; then
    echo "This script is NOT running on a Synology NAS!"
    echo "Copy the script to a folder on the Synology"
    echo "and run it from there."
    exit 1  # Not a Synology NAS
fi

# Get NAS model
model=$(cat /proc/sys/kernel/syno_hw_version)
#modelname="$model"

# Show script version
#echo -e "$script $scriptver\ngithub.com/$repo\n"
echo "$script $scriptver"

# Get DSM full version
productversion=$(/usr/syno/bin/synogetkeyvalue /etc.defaults/VERSION productversion)
buildphase=$(/usr/syno/bin/synogetkeyvalue /etc.defaults/VERSION buildphase)
buildnumber=$(/usr/syno/bin/synogetkeyvalue /etc.defaults/VERSION buildnumber)
smallfixnumber=$(/usr/syno/bin/synogetkeyvalue /etc.defaults/VERSION smallfixnumber)
majorversion=$(/usr/syno/bin/synogetkeyvalue /etc.defaults/VERSION majorversion)
minorversion=$(/usr/syno/bin/synogetkeyvalue /etc.defaults/VERSION minorversion)

# Show DSM full version and model
if [[ $buildphase == GM ]]; then buildphase=""; fi
if [[ $smallfixnumber -gt "0" ]]; then smallfix="-$smallfixnumber"; fi
echo -e "$model DSM $productversion-$buildnumber$smallfix $buildphase"

# Check DSM version
if [[ ! $majorversion -ge "7" ]] && [[ ! $minorversion -ge "2" ]]; then
    echo -e "This script requires DSM 7.2 or later.\n"
    exit 1  # Not DSM 7.2 or later
fi

# Get CPU arch
arch="$(uname -m)"; echo "CPU is $arch"

# Get value of unique
current_unique="$(synogetkeyvalue /etc.defaults/synoinfo.conf unique)"
echo -e "$current_unique\n"

# Check if arch is armv8
if [[ $arch == "armv71" ]]; then
    echo -e "Container Manager is not available for 32-bit CPUs.\n"
    exit
elif [[ $arch == "x86_64" ]]; then
    echo -e "This script is only for ARMv8 CPUs.\n"
    exit
fi

# List of models that need this script
exclude_list=("synology_rtd1296_ds118" "synology_rtd1296_ds218")
exclude_list+=("synology_rtd1296_ds218play" "synology_rtd1296_ds418")
exclude_list+=("synology_rtd1296_ds418j" "synology_armada37xx_ds119j")
exclude_list+=("synology_rtd1296_rs819")

# Check if this model needs this script
if [[ ! ${exclude_list[*]} =~ "$current_unique" ]]; then
    echo -e "You don't need this script for your $model\n"
    exit
fi


restore_unique(){ 
    # Restore unique to original model
    if [[ -n $current_unique ]]; then
        echo "Restoring synoinfo.conf"
        synosetkeyvalue /etc/synoinfo.conf unique "$current_unique"
        synosetkeyvalue /etc.defaults/synoinfo.conf unique "$current_unique"
    fi
}

progbar(){ 
    # $1 is pid of process
    # $2 is string to echo
    string="$2"
    local dots
    local progress
    dots=""
    while [[ -d /proc/$1 ]]; do
        dots="${dots}."
        progress="$dots"
        if [[ ${#dots} -gt "10" ]]; then
            dots=""
            progress="           "
        fi
        echo -ne "  ${2}$progress\r"; sleep 0.3
    done
}

progstatus(){ 
    # $1 is return status of process
    # $2 is string to echo
    # $3 line number function was called from
    local tracestring
    local pad
    tracestring="${FUNCNAME[0]} called from ${FUNCNAME[1]} $3"
    pad=$(printf -- ' %.0s' {1..80})
    [ "$trace" == "yes" ] && printf '%.*s' 80 "${tracestring}${pad}" && echo ""
    if [[ $1 == "0" ]]; then
        echo -e "$2            "

    elif grep "Failed to query package list from server" /tmp/installcm.txt >/dev/null; then
        ding
        echo -e "${Error}ERROR${Off} Failed to query package list from server!"
        install_from_server_failed="yes"

    else
        ding
        echo -e "Line ${LINENO}: ${Error}ERROR${Off} $2 failed!"
        echo "$tracestring"        
        [ -f /tmp/installcm.txt ] && xargs echo < /tmp/installcm.txt && echo ""
        if [[ $exitonerror != "no" ]]; then
            restore_unique
            exit 1  # Skip exit if exitonerror != no
        fi
    fi
    exitonerror=""
    #echo "return: $1"  # debug
}

# shellcheck disable=SC2143
package_status(){ 
    # $1 is package name
    [ "$trace" == "yes" ] && echo "${FUNCNAME[0]} called from ${FUNCNAME[1]}"
    local code
    /usr/syno/bin/synopkg status "${1}" >/dev/null
    code="$?"
    # DSM 7.2       0 = started, 17 = stopped, 255 = not_installed, 150 = broken
    # DSM 6 to 7.1  0 = started,  3 = stopped,   4 = not_installed, 150 = broken
    if [[ $code == "0" ]]; then
        #echo -e "$1 is started\n" >&2  # debug
        return 0
    elif [[ $code == "17" ]] || [[ $code == "3" ]]; then
        #echo -e "$1 is stopped\n" >&2  # debug
        return 1
    elif [[ $code == "255" ]] || [[ $code == "4" ]]; then
        echo -e "$1 is not installed\n" >&2  # debug
        return 255
    elif [[ $code == "150" ]]; then
        echo -e "$1 is broken\n" >&2  # debug
        return 150
    else
        #echo "$code" >&2  # debug
        return "$code"
    fi
}

wait_status(){ 
    # Wait for package to finish stopping or starting
    # $1 is package
    # $2 is start or stop
    [ "$trace" == "yes" ] && echo "${FUNCNAME[0]} called from ${FUNCNAME[1]}"
    local num
    if [[ $2 == "start" ]]; then
        state="0"
    elif [[ $2 == "stop" ]]; then
        state="1"
    fi
    if [[ $state == "0" ]] || [[ $state == "1" ]]; then
        num="0"
        package_status "$1"
        code="$?"
        if [[ $code == "255" ]] || [[ $code == "150" ]]; then
            restore_unique
            exit "$code"
        fi
        while [[ $code != "$state" ]]; do
            sleep 1
            num=$((num +1))
            if [[ $num -gt "20" ]]; then
                break
            fi
            package_status "$1"
        done
    fi
}

package_stop(){ 
    # $1 is package name
    # $2 is package display name
    [ "$trace" == "yes" ] && echo "${FUNCNAME[0]} called from ${FUNCNAME[1]}"
    timeout 5.0m /usr/syno/bin/synopkg stop "$1" >/dev/null &
    pid=$!
    string="Stopping ${Cyan}${2}${Off}"
    progbar "$pid" "$string"
    wait "$pid"
    progstatus "$?" "$string" "line ${LINENO}"

    # Allow package processes to finish stopping
    wait_status "$1" stop
    #sleep 1
}

package_start(){ 
    # $1 is package name
    # $2 is package display name
    [ "$trace" == "yes" ] && echo "${FUNCNAME[0]} called from ${FUNCNAME[1]}"
    timeout 5.0m /usr/syno/bin/synopkg start "$1" >/dev/null &
    pid=$!
    string="Starting ${Cyan}${2}${Off}"
    progbar "$pid" "$string"
    wait "$pid"
    progstatus "$?" "$string" "line ${LINENO}"

    # Allow package processes to finish starting
    wait_status "$1" start
}

# shellcheck disable=SC2317  # Don't warn about unreachable commands in this function
package_uninstall(){ 
    # $1 is package name
    [ "$trace" == "yes" ] && echo "${FUNCNAME[0]} called from ${FUNCNAME[1]}"
    #/usr/syno/bin/synopkg uninstall "$1" >/dev/null &
    /usr/syno/bin/synopkg uninstall "$1" >/tmp/installcm.txt &
    pid=$!
    string="Uninstalling ${Cyan}${1}${Off}"
    progbar "$pid" "$string"
    wait "$pid"
    progstatus "$?" "$string" "line ${LINENO}"
}

# shellcheck disable=SC2317  # Don't warn about unreachable commands in this function
package_install(){ 
    # $1 is package name
    # $2 is /volume2 etc
    [ "$trace" == "yes" ] && echo "${FUNCNAME[0]} called from ${FUNCNAME[1]}"
    #/usr/syno/bin/synopkg install_from_server "$1" "$2" >/dev/null &
    /usr/syno/bin/synopkg install_from_server "$1" "$2" >/tmp/installcm.txt &
    pid=$!
    string="Installing ${Cyan}${1}${Off} on ${Cyan}$2${Off}"
    progbar "$pid" "$string"
    wait "$pid"
    progstatus "$?" "$string" "line ${LINENO}"
}

do_manual_install(){ 
    echo -e "\nDo ${Error}NOT${Off} exit the script or close this window.\n"
    echo -e "Please do a manual install:\n"
    echo -e "  1. Download the latest ContainerManager-${Cyan}armv8${Off} spk file from:"
    echo "     https://archive.synology.com/download/Package/ContainerManager"
    echo -e "  2. Open Package Center."
    echo -e "  3. Click on the Manual Install button."
    echo -e "  4. Click on the Browse button."
    echo -e "  5. Browse to where you saved the ContainerManager spk file."
    echo -e "  6. Select the spk file and click Open."
    echo -e "  7. Click Next and install Container Manager."
    echo -e "  8. Close Package Center."
    echo -e "  9. Return to this window so the script can restore the correct model number."
    echo -e "  10. Type ${Cyan}yes${Off} after you have manually installed Container Manager."
    read -r answer
    if [[ ${answer,,} != "yes" ]]; then
        restore_unique
        exit
    fi
    manual_install="yes"
    echo ""
}


# Check if Container Manager already installed
package_status ContainerManager >/dev/null
code="$?"
#if [[ $(package_status ContainerManager) != "255" ]]; then
if [[ $code != "255" ]]; then
    target=$(readlink "/var/packages/ContainerManager/target")
    targetvol="/$(printf %s "${target:?}" | cut -d'/' -f2 )"
    #targetvol="$(printf %s "${target:?}" | cut -d'/' -f2 )"
    echo -e "Container Manager already installed on $targetvol\n"
    exit
fi

# Backup synoinfo.conf if needed
synoinfo="/etc.defaults/synoinfo.conf"
if [[ ! -f ${synoinfo}.bak ]]; then
    if cp "$synoinfo" "$synoinfo.bak"; then
        echo -e "Backed up synoinfo.conf\n"
        chmod 755 "$synoinfo.bak"
    else
        ding
        echo -e "\n${Error}ERROR 5${Off} Failed to backup synoinfo.conf!"
        exit 1
    fi
fi


# Select volume if there's more than 1
if [[ -z $target ]]; then
    # Get list of available volumes
    volumes=( )
    for v in /volume*; do
        # Ignore /volumeUSB# and /volume0
        if [[ $v =~ /volume[1-9][0-9]?$ ]]; then
            # Ignore unmounted volumes
            if df -h | grep "$v" >/dev/null ; then
                volumes+=("$v")
            fi
        fi
    done

    # Select volume to install Container Manager on
    if [[ ${#volumes[@]} -gt 1 ]]; then
        PS3="Select the volume to install Container Manager on: "
        select targetvol in "${volumes[@]}"; do
            if [[ $targetvol ]]; then
                if [[ -d $targetvol ]]; then
                    echo -e "You selected ${Cyan}${targetvol}${Off}\n"
                    break
                else
                    ding
                    echo -e "${Error}ERROR${Off} $targetvol not found!"
                    exit 1
                fi
            else
                echo "Invalid choice!"
            fi
        done
    elif [[ ${#volumes[@]} -eq 1 ]]; then
        targetvol="${volumes[0]}"
    fi
fi

#exit  # debug
#targetvol=/volume1  # debug


# Change unique to a supported model
echo -e "Editing synoinfo.conf\n"
synosetkeyvalue /etc/synoinfo.conf unique synology_rtd1619b_ds423
synosetkeyvalue /etc.defaults/synoinfo.conf unique synology_rtd1619b_ds423


# ? Download https://global.synologydownload.com/download/Package/spk/ContainerManager/20.10.23-1437/ContainerManager-armv8-20.10.23-1437.spk
# ? Do a Manual Install in Package Center of the .spk file you downloaded.
#
# Install Container Manager
package_install ContainerManager "$targetvol"
if [[ $install_from_server_failed == "yes" ]]; then
    do_manual_install
fi

# Allow package processes to finish starting
#wait_status ContainerManager start


# Stop Container Manager
package_stop ContainerManager "Container Manager"

# Allow package processes to finish stopping
wait_status ContainerManager stop


# Edit /var/packages/ContainerManager/INFO to delete the "exclude_model=..." line
if [[ $manual_install == "yes" ]]; then echo ""; fi
echo -e "Editing ContainerManager INFO\n"
sed -i "/exclude_model=*/d" /var/packages/ContainerManager/INFO

# Restore unique to original model
echo -e "Restoring synoinfo.conf\n"
synosetkeyvalue /etc/synoinfo.conf unique "$current_unique"
synosetkeyvalue /etc.defaults/synoinfo.conf unique "$current_unique"


# Start Container Manager
package_start ContainerManager "Container Manager"

echo -e "\nFinished\n"

echo -e "If Package Center is already open close it and re-open it.\n"

echo "You need to prevent Container Manager from auto updating:"
echo "  1. Go to 'Package Center > Settings > Auto-update'"
echo "  2. Select 'Only packages below'"
echo "  3. Untick Container Manager"
echo -e "  4. Click OK\n"

