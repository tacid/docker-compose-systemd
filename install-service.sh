#!/bin/bash

systemd_dir=/etc/systemd/system/

usage() {
    echo "Usage: $0 [install|remove] app_name working_dir"
}

install() {
    APP_NAME=$1
    DIR_NAME=$2




    if [ -z "$1" -o -z "$2" ]; then
        echo "This script installs docker-compose systemd service"
        usage
        exit 101
    elif [ ! -d "$DIR_NAME" ]; then
        logger -s "There is no such directory: $DIRNAME. Please, submit a correct path to docker-compose working directory"
        usage
        exit 102
    elif [ ! -f "$DIR_NAME/docker-compose.yml" -a ! -f "$DIR_NAME/docker-compose.yaml" ]; then
        logger -s "There is no docker-compose.yml file in provided working directory"
        usage
        exit 103
    fi;

    WORKING_DIR=`realpath $DIR_NAME`

    # =======================================
    echo "Installing $APP_NAME service"

    cat app_name.service | sed "s;/\[working_dir\]/;$WORKING_DIR;" | sed "s;\[APP_NAME\];${APP_NAME^};" > ${systemd_dir}/${APP_NAME,,}.service
    cat app_name-reload.service | sed "s;/\[app_name\]/;${APP_NAME,,};" | sed "s;\[APP_NAME\];${APP_NAME^};" > ${systemd_dir}/${APP_NAME,,}-reload.service
    cat app_name-reload.timer | sed "s;/\[app_name\]/;${APP_NAME,,};" | sed "s;\[APP_NAME\];${APP_NAME^};" > ${systemd_dir}/${APP_NAME,,}-reload.timer

    systemctl daemon-reload
    systemctl enable ${APP_NAME,,} ${APP_NAME,,}-reload
    systemctl start ${APP_NAME,,} ${APP_NAME,,}-reload
}

remove() {
    APP_NAME=$1

    if [ -z "$1" ]; then
        echo "This script removes docker-compose systemd service"
        usage
        exit 101
    fi;
    systemctl stop ${APP_NAME,,} ${APP_NAME,,}-reload
    systemctl disable ${APP_NAME,,} ${APP_NAME,,}-reload
    rm ${systemd_dir}/${APP_NAME,,}.service  ${systemd_dir}/${APP_NAME,,}-reload.service ${systemd_dir}/${APP_NAME,,}-reload.timer
    systemctl daemon-reload
}

RUN_DIR=`pwd`;
cd `dirname $0`;
APP_DIR=`pwd`;

case "$1" in
    install)
        install $2 $3
        ;;
    remove)
        remove $2
        ;;
    *)
        logger -s "Please provide action install or remove"
        usage
        ;;
esac
exit 0
