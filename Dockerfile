# Utilisez l'image PHP officielle
FROM php:7.4-fpm

# Copiez composer.lock et composer.json
COPY composer.lock composer.json /var/www/

# Définissez le répertoire de travail
WORKDIR /var/www

# Installez les dépendances
RUN apt-get update && apt-get install -y \
    build-essential \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    vim \
    unzip \
    git \
    curl \
    libonig-dev \
    libzip-dev

# Effacez le cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Installez les extensions PHP
RUN docker-php-ext-install pdo_mysql mbstring zip exif pcntl

# Installez et configurez l'extension GD
RUN apt-get install -y libfreetype6-dev libjpeg62-turbo-dev libpng-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd

# Installez Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer


# Ajoutez un utilisateur pour l'application Laravel
RUN groupadd -g 1000 www
RUN useradd -u 1000 -ms /bin/bash -g www www

# Copiez le contenu du répertoire de l'application
COPY . /var/www

# Copiez les autorisations du répertoire de l'application
COPY --chown=www:www . /var/www

# Changez l'utilisateur actuel à www
USER www

# Exposez le port 9000 et démarrez le serveur php-fpm
EXPOSE 9000

CMD ["php-fpm"]
