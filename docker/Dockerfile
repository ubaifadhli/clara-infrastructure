FROM webdevops/php-nginx:7.3-alpine

LABEL maintainer="Fadhli Ubai <fadhli.ubai@gmail.com>"

# PHP MongoDB driver has been installed, just need to copy the line into PHP config
WORKDIR /opt/docker/etc
RUN echo 'extension=mongodb.so' >> ./php.ini

# Copy backend files
WORKDIR /var/www/
COPY ./clara-backend  ./clara-backend
RUN chmod -R 777 ./clara-backend

# Copy NGINX webserver config
WORKDIR /opt/docker/etc/nginx/conf.d/
COPY ./default.basic.conf .

# Expose the HTTP & HTTPS port
EXPOSE 80

WORKDIR /var/www

# TODO : Config SSL
# TODO : Config the backend .env file for containerized MongoDB
