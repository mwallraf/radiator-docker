FROM alpine:3.12.0

MAINTAINER Maarten Wallraf <maarten@2nms.com>

ARG TZ='Europe/Brussels'

ENV TZ ${TZ}

RUN apk update && \
    apk add alpine-sdk perl perl-dbi perl-dbd-mysql yaml perl-yaml-syck perl-digest-md5 && \
    apk add perl-ldap perl-digest-sha1 perl-digest-hmac perl-digest-perl-md5 openssl && \
    apk add libevent perl-crypt-openssl-dsa openssl-dev perl-crypt-openssl-rsa && \
    apk add perl-crypt-openssl-random perl-net-ssleay perl-getopt-long supervisor bash tzdata mariadb-client && \
    mkdir /app && \
    mkdir /etc/radiator

RUN mkdir /var/log/radiator && chmod 775 /var/log/radiator

ADD ./src/radiator.tgz /app/

ADD ./etc/supervisord.ini /etc/supervisor.d/radiator.ini

RUN mv /app/Rad* /app/radiator

ADD ./src/contrib/*pm /app/radiator/Radius/

WORKDIR /app/radiator

RUN sed -i "s/require \"timelocal.pl\";/require Time::Local;/g" radiusd && \
    sed -i "s/require \"timelocal.pl\";/require Time::Local;/g" radpwtst && \
    perl Makefile.PL && \
    make install && \
    cp radius.cfg /etc/radiator/radiator.cfg.default && \
    cp dictionary* /etc/radiator/

ADD ./etc/profile.d/aliases.sh /etc/profile.d/aliases.sh

ADD ./etc/radiator/radiator.cfg /etc/radiator/

RUN mkdir /etc/periodic/1min && \
    echo "*/5       *       *       *       *       run-parts /etc/periodic/5min" >> /etc/crontabs/root

CMD [ "supervisord", "-n" ]
