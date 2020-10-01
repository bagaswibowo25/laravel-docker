FROM alpine
# Add alpine edge repositories
RUN rm /etc/apk/repositories
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories
# Install and setup php7.4 package
RUN apk update && apk add php7=7.4.10-r2 php7-tokenizer=7.4.10-r2 php7-session=7.4.10-r2 
RUN apk add php7-bcmath=7.4.10-r2 php7-bz2=7.4.10-r2 php7-common=7.4.10-r2 php7-curl=7.4.10-r2 
RUN apk add php7-fpm=7.4.10-r2 php7-gd=7.4.10-r2 php7-imap=7.4.10-r2 php7-intl=7.4.10-r2 
RUN apk add php7-json=7.4.10-r2 php7-ldap=7.4.10-r2 
RUN apk add php7-mbstring=7.4.10-r2 php7-mysqli=7.4.10-r2 php7-pdo_mysql=7.4.10-r2 
RUN apk add php7-mysqlnd=7.4.10-r2 php7-pdo_pgsql=7.4.10-r2 php7-pgsql=7.4.10-r2 
RUN apk add php7-xml=7.4.10-r2 php7-xmlrpc=7.4.10-r2 php7-zip=7.4.10-r2 
RUN apk add php7-xmlwriter=7.4.10-r2 php7-fileinfo=7.4.10-r2 
RUN apk add php7-dom=7.4.10-r2 php7-json=7.4.10-r2 php7-xmlreader=7.4.10-r2 
RUN apk add php7-ctype=7.4.10-r2 php7-simplexml=7.4.10-r2 php7-pecl-igbinary 
RUN apk add php7-pecl-mailparse php7-opcache=7.4.10-r2
RUN apk add composer
# Add gettext for env support
RUN apk add bash gettext
# Install Nginx
RUN apk add nginx
# Install prestissimo speeding up composer
RUN mkdir /root/.composer
COPY composer.json /root/.composer
RUN cd /root/.composer/ && composer install --no-scripts --no-interaction --no-autoloader --no-dev --prefer-dist
# Copy Laravel App
ARG CACHE_LARAVEL=1
ADD laravel /usr/share/nginx/html/laravel
WORKDIR /usr/share/nginx/html/laravel
RUN composer install --no-scripts --no-interaction --no-autoloader --no-dev --prefer-dist
# Setup Configuration
ARG CACHE_CONFIG=1
COPY site-template-nginx.conf /etc/nginx
COPY www.conf /etc/php7/php-fpm.d
WORKDIR /usr/share/nginx/html/laravel
RUN chown -R nginx:nginx /usr/share/nginx/html/laravel/
ARG CACHE_CLEAR=1
RUN chmod -R 777 storage
RUN cp .env.example .env
RUN composer dump-autoload
RUN php artisan key:generate
COPY docker-startup.sh /usr/share/nginx/html/laravel
RUN chmod +x docker-startup.sh
CMD ./docker-startup.sh