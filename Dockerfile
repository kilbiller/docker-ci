FROM circleci/php:7.4-node

USER root

RUN apt-get update \
	&& apt-get install --no-install-recommends -y \
	python-pip \
	python-setuptools

# Install php-ast extension (for phan)
RUN pecl install ast && echo 'extension=ast.so' > "$PHP_INI_DIR/conf.d/30-ast.ini"

# Install redis extension
RUN curl -L -o /tmp/redis.tar.gz https://github.com/phpredis/phpredis/archive/5.1.1.tar.gz \
	&& tar xfz /tmp/redis.tar.gz \
	&& rm -r /tmp/redis.tar.gz \
	&& mkdir -p /usr/src/php/ext \
	&& mv phpredis-5.1.1 /usr/src/php/ext/redis \
	&& docker-php-ext-install redis

# aws-cli
USER circleci
ENV PATH="/home/circleci/.local/bin:$PATH"
RUN pip install awscli --upgrade --user
