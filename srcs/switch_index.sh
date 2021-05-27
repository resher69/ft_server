#!/bin/bash
if [[ $# -ne 1 ]]
then
        echo "usage: $0 enable/disable."
    	exit 2
elif [ $1 = "enable" ]
then
		sed -i -e '13y/#/ /' /etc/nginx/sites-available/default
        echo "autoindex has been enabled."
elif [ $1 = "disable" ]
then
		sed -i -e '13s/^#*/#/g' /etc/nginx/sites-available/default
        echo "autoindex has been disabled."
else
        echo "usage: $0 enable/disable."
		exit 2
fi
nginx -s reload
