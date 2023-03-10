#!/bin/bash

Green="\033[32m"
Red="\033[31m"
Yellow='\033[33m'
Font="\033[0m"
INFO="[${Green}INFO${Font}]"
ERROR="[${Red}ERROR${Font}]"
WARN="[${Yellow}WARN${Font}]"
Time=$(date +"%Y-%m-%d %T")
INFO(){
echo -e "${Time} ${INFO} ${1}"
}
ERROR(){
echo -e "${Time} ${ERROR} ${1}"
}
WARN(){
echo -e "${Time} ${WARN} ${1}"
}

cd "${IYUU_WORKDIR}"

if [[ -z "${PUID}" || -z "${PGID}" ]] || [[ "${PUID}" = 65534 || "${PGID}" = 65534 ]]; then
    WARN "忽略权限设置。\n使用PUID=0,PGID=0启动。"
    PUID=0 && PGID=0
    groupmod -o -g "$PGID" "${ADD_USER}"
    usermod -o -u "$PUID" "${ADD_USER}"
else
    INFO "权限设置..."
    groupmod -o -g "$PGID" "${ADD_USER}"
    usermod -o -u "$PUID" "${ADD_USER}"
fi

if [ "${IYUU_GIT}" = "gitee" ]; then 
    IYUU_REPO_URL="https://gitee.com/ledc/iyuuplus.git"
else 
    IYUU_REPO_URL="https://github.com/ledccn/IYUUPlus.git"
fi

if [[ ! -d .git ]]; then
    # git clone https://github.com/ledccn/IYUUPlus.git /tmp/IYUU
    # git clone https://gitee.com/ledc/iyuuplus.git /tmp/IYUU
    git clone "${IYUU_REPO_URL}" /tmp/IYUU
    find /tmp/IYUU -mindepth 1 -maxdepth 1 | xargs -I {} cp -r {} ${IYUU_WORKDIR}
    rm -rf /tmp/IYUU
else
    git fetch --all
    git reset --hard origin/master
    git pull
fi

if [[ ! -s .env ]]; then
    cp -f .env.example .env
    sed -i "/SERVER_PROCESS_GROUP/c\SERVER_PROCESS_GROUP='${ADD_USER}'" .env
    sed -i "/SERVER_PROCESS_USER/c\SERVER_PROCESS_USER='${ADD_USER}'" .env
else
    sed -i "/SERVER_PROCESS_GROUP/c\SERVER_PROCESS_GROUP='${ADD_USER}'" .env
    sed -i "/SERVER_PROCESS_USER/c\SERVER_PROCESS_USER='${ADD_USER}'" .env
fi

if [[ -z "${CRON_UPDATE}" ]]; then
    minute=$(($RANDOM % 60))
    hour_start=$(($RANDOM % 6))
    hour_interval=$(($RANDOM % 4 + 6))
    CRON_UPDATE="${minute} ${hour_start}-23/${hour_interval} * * *"
fi

INFO "设置cron..."
# echo "${CRON_UPDATE} cd ${IYUU_WORKDIR} && git fetch --all && git reset --hard origin/master && git pull && chown -R ${PUID}:${PGID} ${IYUU_WORKDIR} && umask ${UMASK} && su-exec ${PUID}:${PGID} php start.php restart -d" | crontab -
echo "${CRON_UPDATE} cd ${IYUU_WORKDIR} && git fetch --all && git reset --hard origin/master && git pull && chown -R ${PUID}:${PGID} ${IYUU_WORKDIR} && umask ${UMASK} && php start.php restart -d" | crontab -

INFO "当前crontab如下；"
crontab -l

INFO "设置目录权限..."
chown -R "${PUID}":"${PGID}" "${IYUU_WORKDIR}"
if [ ! -d /torrents ]; then
    mkdir -p /torrents
    chown "${PUID}":"${PGID}" /torrents
else
    chown "${PUID}":"${PGID}" /torrents
fi
if [ ! -d /BT_backup ]; then
    mkdir -p /BT_backup
    chown "${PUID}":"${PGID}" /BT_backup
else
    chown "${PUID}":"${PGID}" /BT_backup
fi

umask "${UMASK}"

# su-exec "${PUID}":"${PGID}" php /IYUU/start.php start -d
php /IYUU/start.php start -d
crond -f