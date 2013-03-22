#! /bin/sh -e
 set -e
 PATH=/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin
 DAEMON=/home/appadmin/express-sample/app.js
 case "$1" in
     start) forever start $DAEMON ;;
     stop)  forever stop  $DAEMON ;;
     force-reload|restart)
       forever restart $DAEMON ;;
    status)
      if pidof node > /dev/null; then
        exit 0
      else
        exit 1
      fi
    ;;
     *) echo "Usage: /etc/init.d/node {start|stop|restart|force-reload}"
exit 1
;; esac
exit 0