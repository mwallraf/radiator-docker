FROM alpine:3.7

MAINTAINER Maarten Wallraf <maarten@2nms.com>

RUN apk update && \
    apk add alpine-sdk perl perl-dbi perl-dbd-mysql yaml perl-yaml-syck perl-digest-md5 && \
    apk add perl-ldap perl-digest-sha1 perl-digest-hmac perl-digest-perl-md5 openssl && \
    apk add libevent perl-crypt-openssl-dsa openssl-dev perl-crypt-openssl-rsa && \
    apk add perl-crypt-openssl-random perl-net-ssleay perl-getopt-long supervisor && \
    mkdir /app && \
    mkdir /etc/radiator

ADD ./radiator.tgz /app/

ADD ./etc/supervisord.ini /etc/supervisor.d/radiator.ini

RUN mv /app/Rad* /app/radiator

WORKDIR /app/radiator

RUN sed -i "s/require \"timelocal.pl\";/require Time::Local;/g" radiusd && \
    sed -i "s/require \"timelocal.pl\";/require Time::Local;/g" radpwtst && \
    perl Makefile.PL && \
    make install && \
    cp radius.cfg /etc/radiator/radiator.cfg && \
    cp dictionary* /etc/radiator/

CMD [ "supervisord", "-n" ]
