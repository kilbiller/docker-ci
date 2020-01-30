FROM circleci/php:7.4-node

USER root

RUN apt-get update \
	&& apt-get install --no-install-recommends -y \
	python-pip \
	python-setuptools

# Install php-ast extension (for phan)
RUN pecl install ast && echo 'extension=ast.so' > "$PHP_INI_DIR/conf.d/30-ast.ini"

# aws-cli
USER circleci
ENV PATH="/home/circleci/.local/bin:$PATH"
RUN pip install awscli --upgrade --user
