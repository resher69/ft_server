FROM	debian:buster

RUN		apt-get update && apt-get install -y nginx openssl mariadb-server curl unzip php7.3 php7.3-bcmath php7.3-bz2 php7.3-intl php7.3-gd php7.3-mbstring php7.3-mysql php7.3-xml php7.3-zip php7.3-fpm \
		&& curl https://wordpress.org/latest.tar.gz -o /tmp/wordpress.tar.gz \
		&& curl https://files.phpmyadmin.net/phpMyAdmin/5.1.0/phpMyAdmin-5.1.0-all-languages.zip -o /tmp/pma.zip
RUN		tar xf /tmp/wordpress.tar.gz \
		&& mkdir pmatmp && unzip /tmp/pma.zip -d pmatmp && mv $(find ./pmatmp -d -mindepth 1 -maxdepth 1) pma && rmdir pmatmp \
		&& mv wordpress /var/www/html/wordpress \
		&& mv pma /var/www/html/phpmyadmin \
		&& chmod -R 777 /var/www/html/phpmyadmin \
		&& mkdir /var/www/html/resher/ && echo "agardet le sang" > /var/www/html/resher/autoindextest.txt

RUN		openssl genrsa -out /etc/ssl/key.key 2048 \
		&& openssl rsa -in /etc/ssl/key.key -out /etc/ssl/key.key \
		&& openssl req -sha256 -new -key /etc/ssl/key.key -out /tmp/server.csr -subj "/C=FR/ST=42/L=Lyon/O=gougle inc/OU=Org/CN=www.google.biz" \
		&& openssl x509 -req -sha256 -days 365 -in /tmp/server.csr -signkey /etc/ssl/key.key -out /etc/ssl/cert.crt \
		&& chmod 777 /etc/ssl/key.key /etc/ssl/cert.crt

RUN		service mysql start \
		&& service php7.3-fpm start \
		&& echo "ALTER USER root@localhost IDENTIFIED VIA mysql_native_password;" | mysql \
		&& echo "create user user@localhost identified by 'password';" | mysql -u root \
		&& echo "create database wordpress;" | mysql -u root \
		&& echo "grant all privileges on wordpress.* to user@localhost;" | mysql -u root \
		&& echo "flush privileges;" | mysql -u root

COPY	srcs/config_nginx /etc/nginx/sites-available/default
COPY	srcs/config.inc.php /var/www/html/phpmyadmin/config.inc.php
COPY	srcs/wp-config.php /var/www/html/wordpress/wp-config.php
COPY	srcs/switch_index.sh /switch_index.sh
CMD 	service php7.3-fpm start && service mysql start && nginx -g "daemon off;"

EXPOSE	80
EXPOSE	443
