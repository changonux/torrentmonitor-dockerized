# rootfs builder
FROM alpine:3.17.1 as rootfs-builder

COPY rootfs/ /rootfs/
COPY patches/ /tmp/
ADD http://tormon.ru/tm-latest.zip /tmp/tm-latest.zip

RUN apk --no-cache add \
        unzip \
        sqlite \
        patch \
        && \
        unzip /tmp/tm-latest.zip -d /tmp/ && \
        patch -p1 -d /tmp -i /tmp/workaround-fix-k-me.patch && \
    mv /tmp/TorrentMonitor-master/* /rootfs/data/htdocs && \
    cat /rootfs/data/htdocs/db_schema/sqlite.sql | sqlite3 /rootfs/data/htdocs/db_schema/tm.sqlite && \
    mkdir -p /rootfs/var/log/nginx/

# Main image
FROM alpine:3.17.1
MAINTAINER Alexander Fomichev <fomichev.ru@gmail.com>

ENV VERSION="2.0" \
    RELEASE_DATE="" \
    CRON_TIMEOUT="0 * * * *" \
    CRON_COMMAND="php -q /data/htdocs/engine.php >> /var/log/nginx/torrentmonitor_cron_error.log 2>&1" \
    PHP_TIMEZONE="UTC" \
    PHP_MEMORY_LIMIT="512M" \
    LD_PRELOAD="/usr/lib/preloadable_libiconv.so"

COPY --from=rootfs-builder /rootfs/ /

RUN apk --no-cache add \
        nginx \
        shadow \
        php81 \
        php81-common \
        php81-fpm \
        php81-curl \
        php81-sqlite3 \
        php81-pdo_sqlite \
        php81-xml \
        php81-simplexml \
        php81-session \
        php81-iconv \
        php81-mbstring \
        php81-ctype \
        php81-zip \
        php81-dom \
        && \
    apk add gnu-libiconv=1.15-r3 --update-cache --repository http://dl-cdn.alpinelinux.org/alpine/v3.13/community/ && \
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log && \
    ln -sf /dev/stdout /var/log/php-fpm.log

LABEL ru.korphome.version="${VERSION}" \
      ru.korphome.release-date="${RELEASE_DATE}"

VOLUME ["/data/htdocs/db", "/data/htdocs/torrents"]
WORKDIR /
EXPOSE 80

ENTRYPOINT ["/init"]
