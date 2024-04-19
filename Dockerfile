FROM alpine:3.19

ENV PS1="\[\e[32m\][\[\e[m\]\[\e[36m\]\u \[\e[m\]\[\e[37m\]@ \[\e[m\]\[\e[34m\]\h\[\e[m\]\[\e[32m\]]\[\e[m\] \[\e[37;35m\]in\[\e[m\] \[\e[33m\]\w\[\e[m\] \[\e[32m\][\[\e[m\]\[\e[37m\]\d\[\e[m\] \[\e[m\]\[\e[37m\]\t\[\e[m\]\[\e[32m\]]\[\e[m\] \n\[\e[1;31m\]$ \[\e[0m\]" \
    LANG="C.UTF-8" \
    TZ="Asia/Shanghai" \
    APP_ENV=prod \
    IYUU_REPO_URL="https://gitee.com/ledc/iyuuplus-dev.git"

RUN set -ex && \
    apk add --no-cache \
        curl \
        bash \
        openssl  \
        wget \
        zip \
        unzip \
        tzdata \
        composer \
        git \
        libressl \
        tar \
        s6-overlay \
        php82 \
        php82-cli \
        php82-bcmath \
        php82-curl \
        php82-dom \
        php82-mbstring \
        php82-openssl \
        php82-opcache \
        php82-pcntl \
        php82-pdo \
        php82-pdo_sqlite \
        php82-phar \
        php82-posix \
        php82-simplexml \
        php82-sockets \
        php82-session \
        php82-zip \
        php82-gd \
        php82-mysqli \
        php82-pdo_mysql \
        php82-pecl-event \
        php82-xml && \
    echo -e "upload_max_filesize=100M\npost_max_size=108M\nmemory_limit=1024M\ndate.timezone=${TZ}\n" > /etc/php82/conf.d/99-overrides.ini && \
    echo -e "[opcache]\nopcache.enable=1\nopcache.enable_cli=1" >> /etc/php82/conf.d/99-overrides.ini && \
    git config --global pull.ff only && \
    git config --global --add safe.directory /iyuu && \
    git clone --depth 1 ${IYUU_REPO_URL} /iyuu 

COPY --chmod=755 ./rootfs /

VOLUME [ "/iyuu" ]

ENTRYPOINT ["/init"]
