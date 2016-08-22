#!/bin/sh

DOMAIN=DOMAIN
USERNAME=USERNAME
PASSWORD=PASSWORD

LOGFILE="/tmp/ddns_ip_address"
UPDATEPATH="https://ieserver.net/cgi-bin/dip.cgi?username=${USERNAME}&domain=${DOMAIN}&password=${PASSWORD}&updatehost=1"

ip_check() {
  if ! wget -q -O - http://ipcheck.ieserver.net/; then
    logger -t "DDNSd" -p local0.alert -s "Network is not available."
    exit 1
  fi
}

ip_update() {
  if wget -q -O /dev/null $UPDATEPATH; then
    logger -t "DDNSd" -p local0.info "Updated."
    ip_check > $LOGFILE
    exit 0
  else
    logger -t "DDNSd" -p local0.alert -s "DDNS update is failed."
    exit 1
  fi
}

if [ -f $LOGFILE ]; then
  OLD_ADDRESS=$(cat $LOGFILE)
  NEW_ADDRESS=$(ip_check)
  if [ "$OLD_ADDRESS" = "$NEW_ADDRESS" ]; then
    exit 0
  else
    logger -t "DDNSd" -p local0.info "IP Address is chenged..."
    ip_update
  fi
else
  logger -t "DDNSd" -p local0.info "IP Address is not registered..."
  ip_update
fi

