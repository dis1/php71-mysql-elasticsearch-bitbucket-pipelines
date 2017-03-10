FROM debian:jessie

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y

RUN apt-get -y install apt-transport-https lsb-release ca-certificates wget
RUN wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
RUN echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list
RUN apt-get update -y

RUN { \
        echo mysql-community-server mysql-community-server/data-dir select ''; \
        echo mysql-community-server mysql-community-server/root-pass password ''; \
        echo mysql-community-server mysql-community-server/re-root-pass password ''; \
        echo mysql-community-server mysql-community-server/remove-test-db select false; \
    } | debconf-set-selections \
    && apt-get install -y mysql-server

RUN apt-get install -y php7.1-curl php7.1-cli php7.1-intl php7.1-zip php7.1-dom php7.1-mysqlnd php7.1-gd php7.1-mbstring php7.1-fpm php-memcached memcached ssh curl git openjdk-7-jre

RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer

RUN wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -

# https://www.elastic.co/guide/en/elasticsearch/reference/5.0/deb.html
RUN apt-get update && apt-get install -y apt-transport-https && rm -rf /var/lib/apt/lists/* \
	&& echo 'deb http://packages.elasticsearch.org/elasticsearch/2.x/debian stable main' > /etc/apt/sources.list.d/elasticsearch.list

ENV ELASTICSEARCH_VERSION 2.3.3
ENV ELASTICSEARCH_DEB_VERSION 2.3.3

# don't allow the package to install its sysctl file (causes the install to fail)
# Failed to write '262144' to '/proc/sys/vm/max_map_count': Read-only file system
RUN dpkg-divert --rename /usr/lib/sysctl.d/elasticsearch.conf \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends "elasticsearch=$ELASTICSEARCH_DEB_VERSION" \
	&& rm -rf /var/lib/apt/lists/*

RUN apt-get autoclean && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www