FROM debian:wheezy

MAINTAINER Fabio Ribeiro <silva.ribeiro@dafiti.com.br>

# Let the conatiner know that there is no tty
ENV DEBIAN_FRONTEND noninteractive

# Install basic packages
RUN apt-get update && apt-get -y install wget curl pkg-config make \
    libcurl4-gnutls-dev libxml2-dev libpcre3-dev bzip2 procps

# Register new packages
RUN echo "deb http://packages.dotdeb.org wheezy-php56 all" >> /etc/apt/sources.list && \
    echo "deb-src http://packages.dotdeb.org wheezy-php56 all" >> /etc/apt/sources.list && \
    echo "deb http://packages.dotdeb.org wheezy all" >> /etc/apt/sources.list

RUN wget http://www.dotdeb.org/dotdeb.gpg && apt-key add dotdeb.gpg

# Update packages
RUN apt-get update

# Ensure UTF-8 locale
RUN apt-get install locales
RUN sed -i "s/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/" /etc/locale.gen
ENV LANG       en_US.UTF-8
ENV LC_ALL     en_US.UTF-8
RUN locale-gen

# Install and configure Nginx
RUN apt-get install --no-install-recommends -y nginx
RUN echo "\ndaemon off;" >> /etc/nginx/nginx.conf
ADD ./default.conf /etc/nginx/sites-available/default

# Install PHP
RUN apt-get install --no-install-recommends -y php5-cli php5-fpm php5-mysqlnd php5-intl php5-xdebug \
    php5-recode php5-mcrypt php5-memcache php5-memcached php5-imagick \
    php5-curl php5-xsl php5-dev php5-tidy php5-xmlrpc php5-gd php5-pspell \
    php5-ldap php-pear

# Configure PHP-FPM
ADD www.conf /etc/php5/fpm/pool.d/www.conf

# PECL - AMQP Extension
WORKDIR /tmp
RUN wget https://github.com/alanxz/rabbitmq-c/archive/v0.5.2.tar.gz && tar -xvzf v0.5.2.tar.gz

WORKDIR /tmp/rabbitmq-c-0.5.2
RUN autoreconf -i \
    && ./configure \
    && make \
    && make install \
    && pecl install amqp \
    && echo "extension=amqp.so" >> /etc/php5/mods-available/amqp.ini

RUN ln -s /etc/php5/mods-available/amqp.ini /etc/php5/fpm/conf.d/20-amqp.ini \
    && ln -s /etc/php5/mods-available/amqp.ini /etc/php5/cli/conf.d/20-amqp.ini

# PECL - Solr Extension
RUN pecl install solr \
    && echo "extension=solr.so" >> /etc/php5/mods-available/solr.ini

RUN ln -s /etc/php5/mods-available/solr.ini /etc/php5/fpm/conf.d/20-solr.ini \
    && ln -s /etc/php5/mods-available/solr.ini /etc/php5/cli/conf.d/20-solr.ini

# Install PEAR packages
RUN pear upgrade PEAR && pear config-set auto_discover 1 && \
    pear channel-discover pear.phing.info && \
    pear install phing/phing

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/bin/composer

# Install MySQL-Client
RUN apt-get install --no-install-recommends -y mysql-client

# Install Java JDK 7
RUN apt-get install --no-install-recommends -y openjdk-7-jdk

# Set Java version
RUN update-alternatives --set java /usr/lib/jvm/java-7-openjdk-amd64/jre/bin/java

# Install ANT
RUN apt-get install --no-install-recommends -y ant ant-contrib

RUN ln -s /usr/share/java/ant-contrib.jar /usr/share/ant/lib/

# Install Supervisor
RUN apt-get install -y supervisor
ADD nginx-fpm.conf /etc/supervisor/conf.d/nginx-fpm.conf

WORKDIR /

EXPOSE 80

CMD ["/usr/bin/supervisord"]
