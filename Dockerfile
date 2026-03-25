FROM php:8.1-apache

RUN docker-php-ext-install mysqli pdo pdo_mysql && a2enmod rewrite

# Allow .htaccess overrides
RUN sed -i 's|AllowOverride None|AllowOverride All|g' /etc/apache2/apache2.conf

# Copy app into a subfolder so URL stays /hr-app/
COPY . /var/www/html/hr-app/

EXPOSE 80
