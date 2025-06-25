# Use official PHP 8.2 FPM base image
FROM php:8.2-fpm

# Install system dependencies & PHP extensions
RUN apt-get update && apt-get install -y \
    git \
    curl \
    zip \
    unzip \
    nginx \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libonig-dev \
    libzip-dev \
    supervisor \
    openssh-server \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo_mysql mbstring zip gd bcmath

# Install Composer globally
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install Node.js and npm (Node 20.x)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm@latest

# Clone Laravel project (replace URL with your repo)
RUN git clone https://github.com/sna1205/DevOps_Final.git /var/www/laravel-app
WORKDIR /var/www/laravel-app
RUN composer install

# Copy default nginx config
COPY ./nginx.conf /etc/nginx/sites-available/default

# Setup SSH (optional)
RUN mkdir /var/run/sshd
RUN echo 'root:rootpassword' | chpasswd

# Expose ports for web (8080) and SSH (22)
EXPOSE 8080 22

# Copy supervisor config
COPY ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Start supervisord to run php-fpm, nginx, and sshd together
CMD ["/usr/bin/supervisord", "-n"]
