FROM ubuntu:18.04

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
	nasm \
	libjpeg-dev \
	libpng-dev

RUN wget -q -O /tmp/libpng12.deb http://mirrors.kernel.org/ubuntu/pool/main/libp/libpng/libpng12-0_1.2.54-1ubuntu1_amd64.deb \
	&& dpkg -i /tmp/libpng12.deb \
	&& rm /tmp/libpng12.deb

RUN ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime \
	&& export DEBIAN_FRONTEND=noninteractive \
	&& apt-get install -y tzdata \
	&& dpkg-reconfigure --frontend noninteractive tzdata

# PHP
RUN add-apt-repository ppa:ondrej/php \
	&& apt-get update \
	&& apt-get install -y \
	php7.3 \
	php7.3-curl \
	php7.3-gd \
	php7.3-dev \
	php7.3-xml \
	php7.3-bcmath \
	php7.3-mysql \
	php7.3-mbstring \
	php7.3-zip \
	php7.3-json \
	php7.3-intl \
	php-xdebug

# Install php-ast extension (for phan)
RUN curl -fsSL 'https://github.com/nikic/php-ast/archive/v1.0.1.tar.gz' -o php-ast.tar.gz \
	&& mkdir -p php-ast \
	&& tar -xzf php-ast.tar.gz -C php-ast --strip-components=1 \
	&& rm php-ast.tar.gz \
	&& ( \
	cd php-ast \
	&& phpize \
	&& ./configure \
	&& make -j"$(getconf _NPROCESSORS_ONLN)" \
	&& make install \
	) \
	&& rm -r php-ast \
	&& echo -e 'extension=ast.so' > /etc/php/7.3/cli/conf.d/30-ast.ini

# Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
	php -r "if (hash_file('SHA384', 'composer-setup.php') === '$(wget -q -O - https://composer.github.io/installer.sig)') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
	php composer-setup.php && \
	php -r "unlink('composer-setup.php');" && \
	mv composer.phar /usr/local/bin/composer && \
	chmod +x /usr/local/bin/composer
RUN command -v composer

# Node.js
RUN curl -sL https://deb.nodesource.com/setup_10.x -o nodesource_setup.sh && \
	bash nodesource_setup.sh && \
	apt-get install nodejs -y

# Yarn
RUN cd /opt \
	&& wget https://yarnpkg.com/downloads/1.17.0/yarn-v1.17.0.tar.gz \
	&& tar zvxf yarn-v1.17.0.tar.gz

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

ENV PATH=/opt/yarn-v1.17.0/bin/:$PATH
ENV COMPOSER_ALLOW_SUPERUSER=1
