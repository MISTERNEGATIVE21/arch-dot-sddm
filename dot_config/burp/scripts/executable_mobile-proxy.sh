#!/usr/bin/env bash
set -e

source $HOME/.config/burp/scripts/env.sh

function cert() {
    cert_dir=$1
    if [ -z "$cert_dir" ]; then
        echo "Usage: $0 cert <cert_dir>"
        return
    fi
    cert_name=$(basename $cert_dir)
    openssl x509 -inform der -in $cert_dir -out /tmp/$cert_name.pem
    # needed for old method
    new_cert_name=$(openssl x509 -inform PEM -subject_hash_old -in /tmp/$cert_name.pem | head -1).0
    adb root
    adb remount
    adb push /tmp/$cert_name.pem /sdcard/Download/$cert_name.pem
    echo "Certificate pushed successfully"
    echo "Android Settings -> Security -> Encryption & Credentials -> Install a certificate -> Choose CA Certificate"
}

start() {
    waydroid_tun=$(\ip route | grep waydroid | awk '{print $9}')
    echo "Proxying through $waydroid_tun:$BURP_PORT"
    adb shell settings put global http_proxy "$waydroid_tun:$BURP_PORT"
    echo "proxy started"
}

stop() {
    adb shell settings put global http_proxy :0
    adb reverse --remove-all
    echo "proxy stopped"
}

case $1 in
"start")
    start
    ;;
"stop")
    stop
    ;;
"cert")
    cert $2
    ;;
*)
    echo "Usage: $0 start|stop|cert"
    ;;
esac