#!/bin/sh


if [ -d $1 ]; then
	echo '############################################'
	echo '##use ./instalar_server.sh seusite.com.br###'
	echo '############################################'
	exit
else
  echo 'Iniciando a instalação nginx + php7.2 + mariadb + phpmyadmin'
	
fi

mkdir $1

cd $1

touch access.log

touch error.log

touch default.conf

mkdir html datadir

cat <<EOF > html/index.php

<?php
phpinfo();
?>

EOF

cat <<EOF > default.conf
server {
    listen 80;
    server_name  localhost;
    index index.php index.html;
    try_files \$uri \$uri/ /index.php?\$args;
    error_log  /var/log/nginx/error.log;
    access_log /var/log/nginx/access.log;
    root /var/www/html;

    location ~ \.php$ {
        try_files \$uri \$uri/ /index.php?\$args;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass php72.$1:9000;
        fastcgi_index index.php;
	fastcgi_read_timeout 1800; 
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_param PATH_INFO \$fastcgi_path_info;
	client_max_body_size 10M;
    }
}
EOF

chmod 777 access.log default.conf error.log
chmod 777 -R html datadir

docker network create intranet

echo "Instalando nginx para" $1

docker run --name nginx.$1 --network=intranet --restart unless-stopped -l traefik.port=80 -l traefik.frontend.rule=Host:$1 -l traefik.docker.network=web -l traefik.enable=true -v $PWD/html:/var/www/html -v $PWD/default.conf:/etc/nginx/conf.d/default.conf -v $PWD/error.log:/var/log/nginx/error.log -d nginx && docker network connect web nginx.$1


echo "Instalando php 7.2 para" $1

docker run --name php72.$1 --network=intranet --restart always -l traefik.enable=false -v $PWD/html:/var/www/html -d php:7.2-fpm-stretch

docker exec -it php72.$1 sh -c 'apt-get update && apt-get install -y zlib1g-dev libc-client-dev libkrb5-dev libpng-dev libjpeg-dev && rm -r /var/lib/apt/lists/*'
docker exec -it php72.$1 sh -c 'docker-php-ext-configure imap --with-kerberos --with-imap-ssl && docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr && docker-php-ext-install imap zip mysqli mbstring gd opcache exif'


docker exec -it php72.$1 sh -c " { echo 'short_open_tag = off;' ; echo 'upload_max_filesize = 10M;' ; echo 'post_max_size = 10M;';} >> /usr/local/etc/php/php.ini && { echo 'opcache.memory_consumption=128'; echo 'opcache.interned_strings_buffer=8'; echo 'opcache.max_accelerated_files=4000'; echo 'opcache.revalidate_freq=2'; echo 'opcache.fast_shutdown=1'; echo 'opcache.enable_cli=1'; } >> /usr/local/etc/php/conf.d/opcache-recommended.ini"




echo "Instalando mariadb para" $1
docker run --name mariadb.$1 --network=intranet --restart always -l traefik.enable=false -v $PWD/datadir:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=$1 -e MYSQL_DATABASE=wordpress -d mariadb --sql-mode="ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION"

echo "Instalando phpmyadmin para" $1
docker run --name phpmyadmin.$1 --network=intranet -p 81:80 -l traefik.enable=false -d -e PMA_HOST=mariadb.$1  phpmyadmin/phpmyadmin


docker network connect web nginx.$1

docker restart nginx.$1



docker ps
