FROM ubuntu:18.04

RUN apt-get update && apt-get install -y \
	software-properties-common \
	curl \
	git \
	ssh \
	tar \
	gzip

# PHP
RUN add-apt-repository ppa:ondrej/php \
	&& DEBIAN_FRONTEND=noninteractive apt-get install -y \
	php7.3 \
	php7.3-dev \
	php7.3-curl \
	php7.3-gd \
	php7.3-xml \
	php7.3-bcmath \
	php7.3-mysql \
	php7.3-mbstring \
	php7.3-zip \
	php7.3-json \
	php7.3-intl

# Install xdebug
RUN pecl install xdebug \
	&& echo 'zend_extension=xdebug.so' > /etc/php/7.3/cli/conf.d/30-xdebug.ini

# Install php-ast extension (for phan)
RUN pecl install ast \
	&& echo 'extension=ast.so' > /etc/php/7.3/cli/conf.d/30-ast.ini

# Composer
ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_HOME /tmp
ENV COMPOSER_VERSION 1.9.1
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer --version=${COMPOSER_VERSION}
RUN command -v composer

# Node.js
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash \
	&& apt-get install nodejs -y

# Yarn
RUN curl -o- -L https://yarnpkg.com/install.sh | bash

# aws-cli
RUN apt-get update \
	&& apt-get install -y python-pip \
	&& pip install awscli --upgrade --user \
	&& ln -s /root/.local/bin/aws /usr/local/bin/aws

# docker
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - \
	&& add-apt-repository \
	"deb [arch=amd64] https://download.docker.com/linux/ubuntu \
	$(lsb_release -cs) \
	stable" \
	&& apt-get update \
	&& apt-get install -y docker-ce
