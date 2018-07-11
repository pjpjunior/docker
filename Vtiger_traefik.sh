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
<meta http-equiv="refresh" content="0; URL=/vtigercrm/">
<meta name="keywords" content="automatic redirection">
</head>
<body>
<a href="/vtigercrm/">Vtiger CRM</a> 
manually.
</body>
</html>

EOF
docker network create intranet

echo "Instalando nginx para" $1
docker run --name nginx.$1 --network=intranet -l traefik.frontend.rule=Host:$1 -v $PWD/html:/var/www/html -v $PWD/default.conf:/etc/nginx/conf.d/default.conf:ro -v $PWD/error.log:/var/log/nginx/error.log -d nginx

echo "Instalando php 7.2 para" $1
docker run --name php72.$1 --network=intranet -v $PWD/html:/var/www/html -d php:7.2-fpm-stretch

docker exec -it php72.$1 docker-php-ext-install mysqli

docker exec -it php72.vtiger.local sh -c 'echo "short_open_tag = off" >> /usr/local/etc/php/php.ini'



echo "Instalando mariadb para" $1
docker run --name mariadb.vtiger.local --network=intranet -v $PWD/datadir:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=vtiger.local -d mariadb --sql-mode="ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION"

echo "Instalando phpmyadmin para" $1
docker run --name phpmyadmin.$1 --network=intranet -d -e PMA_HOST=mariadb.$1  phpmyadmin/phpmyadmin


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
	fastcgi_read_timeout 1200; 
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_param PATH_INFO \$fastcgi_path_info;
    }
}
EOF

chmod 777 access.log default.conf error.log
chmod 777 -R html datadir

cd html

wget https://sourceforge.net/projects/vtigercrm/files/vtiger%20CRM%207.1.0/Core%20Product/vtigercrm7.1.0.tar.gz && tar -zxvf vtigercrm7.1.0.tar.gz && rm -rf vtigercrm7.1.0.tar.gz

docker restart php72.$1 nginx.$1

docker ps

echo "NGINX" $1
docker inspect nginx.$1 |grep IPAddress

echo "PHPMYADMIN" $1
docker inspect phpmyadmin.$1 |grep IPAddress
