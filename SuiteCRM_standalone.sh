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

cat <<EOF > html/index.html

<html>
<head>
<title>A web page that points a browser to a different page after 2 seconds</title>
<meta http-equiv="refresh" content="0; URL=/SuiteCRM/">
<meta name="keywords" content="">
</head>
<body>
<a href="/SuiteCRM/">SuiteCRM</a> 
manually.
</body>
</html>

EOF

docker network create intranet

echo "Instalando nginx para" $1
docker run --name nginx.$1 --network=intranet -p 80:80 --restart always -v $PWD/html:/var/www/html -v $PWD/default.conf:/etc/nginx/conf.d/default.conf:ro -v $PWD/error.log:/var/log/nginx/error.log -d nginx

echo "Instalando php 7.2 para" $1
docker run --name php72.$1 --network=intranet --restart always -v $PWD/html:/var/www/html -d php:7.2-fpm-stretch

docker exec -it php72.$1 sh -c 'apt-get update && apt-get install -y zlib1g-dev libc-client-dev libkrb5-dev && rm -r /var/lib/apt/lists/*'
docker exec -it php72.$1 sh -c 'docker-php-ext-configure imap --with-kerberos --with-imap-ssl && docker-php-ext-install imap zip mysqli mbstring gd'



docker exec -it php72.$1 sh -c 'echo "short_open_tag = off;" >> /usr/local/etc/php/php.ini && echo "upload_max_filesize = 10M;" >> /usr/local/etc/php/php.ini && echo "post_max_size = 10M;" >> /usr/local/etc/php/php.ini'

#docker exec -it php72.teste sh -c 'echo "short_open_tag = off;" >> /usr/local/etc/php/php.ini && echo "upload_max_filesize = 10M;" >> /usr/local/etc/php/php.ini && echo "post_max_size = 10M;" >> /usr/local/etc/php/php.ini'

echo "Instalando mariadb para" $1
docker run --name mariadb.$1 --network=intranet --restart always -l traefik.enable=false -v $PWD/datadir:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=$1 -d mariadb --sql-mode="ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION"

echo "Instalando phpmyadmin para" $1
docker run --name phpmyadmin.$1 --network=intranet -l traefik.enable=false -d -e PMA_HOST=mariadb.$1  phpmyadmin/phpmyadmin

docker network connect web nginx.$1

cat <<EOF > default.conf
server {
    index index.php index.html;
    server_name php-docker.local;
    error_log  /var/log/nginx/error.log;
    access_log /var/log/nginx/access.log;
    root /var/www/html;

    location ~ \.php$ {
        try_files \$uri = 404;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass $(docker ps -aqf 'name=php72.'$1):9000;
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

cd html

wget https://suitecrm.com/files/160/SuiteCRM-7.10.7/297/SuiteCRM-7.10.7.zip && unzip SuiteCRM-7.10.7.zip && mv SuiteCRM-7.10.7 SuiteCRM && rm -rf SuiteCRM-7.10.7.zip

cd SuiteCRM && wget https://crowdin.com/backend/download/project/suitecrmtranslations/pt-BR.zip && unzip pt-BR.zip && rm pt-BR.zip

docker restart php72.$1 nginx.$1

docker ps

echo "NGINX" $1
docker inspect nginx.$1 |grep IPAddress

