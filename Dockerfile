FROM alpine
# Add alpine edge repositories
RUN rm /etc/apk/repositories
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories
# Install and setup php7.4 package
RUN apk update && apk add php7 php7-tokenizer php7-session php7-bcmath php7-bz2 php7-common php7-curl php7-fpm php7-gd php7-json php7-mbstring php7-mysqli php7-pdo_mysql php7-mysqlnd php7-xml php7-zip php7-fileinfo php7-ctype php7-dom
RUN apk add composer
# Add gettext for env support
RUN apk add bash gettext
# Install Nginx
RUN apk add nginx
# Install prestissimo speeding up composer
RUN mkdir /root/.composer
COPY composer.json /root/.composer
RUN cd /root/.composer/ && composer install --no-scripts --no-interaction --no-autoloader --no-dev --prefer-dist -vvv
# Copy Laravel App
ARG CACHE_LARAVEL=1
ADD laravel /usr/share/nginx/html/laravel
WORKDIR /usr/share/nginx/html/laravel
RUN composer install --no-scripts --no-interaction --no-autoloader --no-dev --prefer-dist -vvv
# Setup Configuration
ARG CACHE_CONFIG=1
COPY site-template-nginx.conf /etc/nginx
COPY www.conf /etc/php7/php-fpm.d
WORKDIR /usr/share/nginx/html/laravel
RUN chown -R nginx:nginx /usr/share/nginx/html/laravel/
RUN chmod -R 777 storage/
RUN cp .env.example .env
RUN composer dump-autoload
RUN php artisan key:generate
COPY docker-startup.sh /usr/share/nginx/html/laravel
RUN chmod +x docker-startup.sh
CMD ./docker-startup.sh