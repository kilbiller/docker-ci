FROM php:7.4-cli

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install --no-install-recommends -y \
	apt-transport-https \
	ca-certificates \
	curl \
	git \
	gnupg-agent \
	gzip \
	jq \
	python-pip \
	python-setuptools \
	software-properties-common \
	ssh \
	sudo \
	tar \
	unzip

# Install xdebug
RUN pecl install xdebug \
	&& echo 'zend_extension=xdebug.so' > "$PHP_INI_DIR/conf.d/30-xdebug.ini"

# Install php-ast extension (for phan)
RUN pecl install ast \
	&& echo 'extension=ast.so' > "$PHP_INI_DIR/conf.d/30-ast.ini"

# Node.js
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash \
	&& apt-get install --no-install-recommends -y nodejs

# docker
RUN set -ex \
	&& export DOCKER_VERSION=$(curl --silent --fail --retry 3 https://download.docker.com/linux/static/stable/x86_64/ | grep -o -e 'docker-[.0-9]*\.tgz' | sort -r | head -n 1) \
	&& DOCKER_URL="https://download.docker.com/linux/static/stable/x86_64/${DOCKER_VERSION}" \
	&& echo "Docker URL: $DOCKER_URL" \
	&& curl --silent --show-error --location --fail --retry 3 --output /tmp/docker.tgz "${DOCKER_URL}" \
	&& ls -lha /tmp/docker.tgz \
	&& tar -xz -C /tmp -f /tmp/docker.tgz \
	&& mv /tmp/docker/* /usr/bin \
	&& rm -rf /tmp/docker /tmp/docker.tgz \
	&& which docker \
	&& (docker version || true)

# Add circleci user
RUN groupadd --gid 3434 circleci \
	&& useradd --uid 3434 --gid circleci --shell /bin/bash --create-home circleci \
	&& echo 'circleci ALL=NOPASSWD: ALL' >> /etc/sudoers.d/50-circleci \
	&& echo 'Defaults    env_keep += "DEBIAN_FRONTEND"' >> /etc/sudoers.d/env_keep

USER circleci

ENV PATH="/home/circleci/.local/bin:$PATH"

# Composer
ENV COMPOSER_HOME /tmp
ENV COMPOSER_VERSION 1.9.1
RUN mkdir -p "$HOME/.local/bin" \
	&& curl -sS https://getcomposer.org/installer | php -- --install-dir="$HOME/.local/bin" --filename=composer --version=${COMPOSER_VERSION}
RUN composer --version

# Yarn
ENV YARN_VERSION 1.21.1
RUN curl -o- -L https://yarnpkg.com/install.sh | bash -s -- --version $YARN_VERSION
ENV PATH="/home/circleci/.yarn/bin:/home/circleci/.config/yarn/global/node_modules/.bin:$PATH"

# aws-cli
RUN pip install awscli --upgrade --user
