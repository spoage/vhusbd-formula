{%- from "vhusbd/map.jinja" import vhusbd with context -%}

#!/bin/sh

### BEGIN INIT INFO
# Provides:             vhusbd
# Required-Start:       $remote_fs
# Required-Stop:        $remote_fs
# Should-Start:         $network
# Should-Stop:
# Default-Start:        2 3 4 5
# Default-Stop:         0 1 6
# Short-Description:    USB over IP server daemon
# Description:          USB over IP server daemon
### END INIT INFO

NAME=vhusbd
DESC="USB over IP server daemon"
PATH=/sbin:/bin:/usr/sbin:/usr/bin
DAEMON_SBIN={{ vhusbd.server.binary.install_dir }}/$NAME
DAEMON_DEFS=/etc/default/$NAME
DAEMON_CONF={{ vhusbd.server.config.path }}
DAEMON_LOG={{ vhusbd.server.log_file }}

[ -x "$DAEMON_SBIN" ] || exit 0
[ -s "$DAEMON_DEFS" ] && . $DAEMON_DEFS
[ -n "$DAEMON_CONF" ] || exit 0

DAEMON_OPTS="-b -c $DAEMON_CONF -r $DAEMON_LOG $DAEMON_OPTS"

STARTSTOP_OPTS="$STARTSTOP_VERBOSITY --exec $DAEMON_SBIN $STARTSTOP_OPTS"

. /lib/lsb/init-functions

case "$1" in
  start)
        log_daemon_msg "Starting $DESC" "$NAME"
        start-stop-daemon --start --oknodo $STARTSTOP_OPTS -- $DAEMON_OPTS >/dev/null
        log_end_msg "$?"
        ;;
  stop)
        log_daemon_msg "Stopping $DESC" "$NAME"
        start-stop-daemon --stop --oknodo --quiet $STARTSTOP_OPTS
        log_end_msg "$?"
        ;;
  restart)
        $0 stop
        sleep 8
        $0 start
        ;;
  status)
        status_of_proc "$DAEMON_SBIN" "$NAME"
        exit $?
        ;;
  *)
        N=/etc/init.d/$NAME
        echo "Usage: $N {start|stop|restart|status}" >&2
        exit 1
        ;;
esac

exit 0
