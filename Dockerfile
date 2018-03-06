FROM ubuntu:16.04

RUN export LC_ALL=C.UTF-8
RUN DEBIAN_FRONTEND=noninteractive
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

RUN apt-get update && apt-get install -y \
	autoconf \
	autogen \
	language-pack-en-base \
	wget \
	curl \
	ssh \
	openssh-client \
	git \
	build-essential \
	apt-utils \
	software-properties-common \
	python-software-properties \
	nasm \
	libjpeg-dev \
	libpng-dev

RUN wget -q -O /tmp/libpng12.deb http://mirrors.kernel.org/ubuntu/pool/main/libp/libpng/libpng12-0_1.2.54-1ubuntu1_amd64.deb \
	&& dpkg -i /tmp/libpng12.deb \
	&& rm /tmp/libpng12.deb

# PHP
RUN LC_ALL=en_US.UTF-8 add-apt-repository ppa:ondrej/php
RUN apt-get update && apt-get install -y --allow-unauthenticated \
	php7.1 \
	php7.1-curl \
	php7.1-gd \
	php7.1-dev \
	php7.1-xml \
	php7.1-bcmath \
	php7.1-mysql \
	php7.1-mbstring \
	php7.1-zip \
	php7.1-json \
	php7.1-intl \
	php-xdebug
RUN command -v php

# Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
	php -r "if (hash_file('SHA384', 'composer-setup.php') === '$(wget -q -O - https://composer.github.io/installer.sig)') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
	php composer-setup.php && \
	php -r "unlink('composer-setup.php');" && \
	mv composer.phar /usr/local/bin/composer && \
	chmod +x /usr/local/bin/composer
RUN command -v composer

# Node.js
RUN curl -sL https://deb.nodesource.com/setup_8.x -o nodesource_setup.sh && \
	bash nodesource_setup.sh && \
	apt-get install nodejs -y

# Yarn
RUN cd /opt \
	&& wget https://yarnpkg.com/downloads/1.5.1/yarn-v1.5.1.tar.gz \
	&& tar zvxf yarn-v1.5.1.tar.gz

ENV PATH=/opt/yarn-v1.5.1/bin/:$PATH
ENV COMPOSER_ALLOW_SUPERUSER=1

# Other
RUN mkdir ~/.ssh && touch ~/.ssh_config
