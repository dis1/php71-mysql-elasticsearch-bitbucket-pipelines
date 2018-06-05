FROM ubuntu:16.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y

RUN apt -y install software-properties-common locales && locale-gen en_US.UTF-8 && export LANG=en_US.UTF-8 && add-apt-repository -y ppa:ondrej/php && apt -y update

RUN { \
        echo mysql-community-server mysql-community-server/data-dir select ''; \
        echo mysql-community-server mysql-community-server/root-pass password ''; \
        echo mysql-community-server mysql-community-server/re-root-pass password ''; \
        echo mysql-community-server mysql-community-server/remove-test-db select false; \
    } | debconf-set-selections \
    && apt-get install -y mysql-server

RUN apt-get install -y php7.1-curl php7.1-cli php7.1-intl php7.1-zip php7.1-dom php7.1-mysqlnd php7.1-gd php7.1-mbstring php7.1-fpm php7.1-bcmath php-memcached memcached ssh curl git openjdk-8-jre

RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer

RUN wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -

# https://www.elastic.co/guide/en/elasticsearch/reference/5.0/deb.html
RUN apt-get update && apt-get install -y apt-transport-https && rm -rf /var/lib/apt/lists/* \
	&& echo 'deb http://packages.elasticsearch.org/elasticsearch/2.x/debian stable main' > /etc/apt/sources.list.d/elasticsearch.list

ENV ELASTICSEARCH_VERSION 2.3.3
ENV ELASTICSEARCH_DEB_VERSION 2.3.3

RUN dpkg-divert --rename /usr/lib/sysctl.d/elasticsearch.conf \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends "elasticsearch=$ELASTICSEARCH_DEB_VERSION" \
	&& rm -rf /var/lib/apt/lists/*

RUN apt-get autoclean && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www
