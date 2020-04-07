#------------------------------------------------------------------------------
# Set the base image for subsequent instructions:
#------------------------------------------------------------------------------
FROM alpine:3.11
MAINTAINER Siarhei Navatski <navatski@gmail.com>, Andrey Aleksandrov <alex.demion@gmail.com>

#------------------------------------------------------------------------------
# Environment variables:
#------------------------------------------------------------------------------
ENV VERSION="1.8.2" \
    RELEASE_DATE="03.01.2020" \
    CRON_TIMEOUT="0 * * * *" \
    CRON_COMMAND="php -q /data/htdocs/engine.php >> /var/log/nginx/torrentmonitor_cron_error.log 2>\&1" \
    PHP_TIMEZONE="UTC" \
    PHP_MEMORY_LIMIT="512M" \
    LD_PRELOAD="/usr/local/lib/preloadable_libiconv.so"

#------------------------------------------------------------------------------
# Populate root file system:
#------------------------------------------------------------------------------
ADD rootfs /

#------------------------------------------------------------------------------
# Install:
#------------------------------------------------------------------------------
RUN apk update \
    && apk upgrade \
    && apk --no-cache add --update -t deps wget unzip sqlite \
    && apk --no-cache add nginx gnu-libiconv php7-common php7-fpm php7-curl \
                          php7-sqlite3 php7-pdo_sqlite php7-iconv php7-json \
                          php7-ctype php7-zip \
    && wget -q http://korphome.ru/torrent_monitor/tm-latest.zip -O /tmp/tm-latest.zip \
    && unzip /tmp/tm-latest.zip -d /tmp/ \
    && mv /tmp/TorrentMonitor-master/* /data/htdocs \
    && cat /data/htdocs/db_schema/sqlite.sql | sqlite3 /data/htdocs/db_schema/tm.sqlite \
    && mkdir -p /var/log/nginx/ \
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log \
    && ln -sf /dev/stdout /var/log/php-fpm.log \
    && apk del --purge deps; rm -rf /tmp/* /var/cache/apk/*
#------------------------------------------------------------------------------
# Build custom libiconv
# because packaged one had gets() bug until version 1.14
# No more needed since Alpine 3.10
#------------------------------------------------------------------------------
#    && rm /usr/bin/iconv \
#    && curl -SL http://ftpmirror.gnu.org/libiconv/libiconv-1.16.tar.gz | tar -xz -C /tmp \
#    && cd /tmp/libiconv-1.16 \
#    && ./configure --prefix=/usr/local \
#    && make && make install \

#------------------------------------------------------------------------------
# Set labels:
#------------------------------------------------------------------------------
LABEL ru.korphome.version="${VERSION}" \
      ru.korphome.release-date="${RELEASE_DATE}"

#------------------------------------------------------------------------------
# Set volumes, workdir, expose ports and entrypoint:
#------------------------------------------------------------------------------
VOLUME ["/data/htdocs/db", "/data/htdocs/torrents"]
WORKDIR /
EXPOSE 80
ENTRYPOINT ["/init"]
