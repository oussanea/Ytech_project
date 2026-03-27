FROM php:8.1-apache

# Install PHP extensions
RUN docker-php-ext-install mysqli pdo pdo_mysql && a2enmod rewrite ssl

# Allow .htaccess overrides
RUN sed -i 's|AllowOverride None|AllowOverride All|g' /etc/apache2/apache2.conf

# Generate self-signed SSL certificate
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/hr-app.key \
    -out /etc/ssl/certs/hr-app.crt \
    -subj "/C=MA/ST=Casablanca-Settat/L=Casablanca/O=HR System/OU=IT/CN=192.168.56.10"

# Enable default SSL site
RUN a2ensite default-ssl

# Copy SSL Apache config
COPY docker/ssl.conf /etc/apache2/sites-available/default-ssl.conf

# Copy app into subfolder so URL stays /hr-app/
COPY . /var/www/html/hr-app/

EXPOSE 80 443
