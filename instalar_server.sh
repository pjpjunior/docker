#!/bin/sh


if [ -d $1 ]; then
	echo '############################################'
	echo '##use ./instalar_server.sh seusite.com.br###'
	echo '############################################'
	exit
else
  echo 'Iniciando a instalação nginx + php7.2'
	
fi

touch access.log

touch error.log

touch default.conf

mkdir html

cat <<EOF > html/index.php
<?php

phpinfo();

EOF


echo "Instalando nginx para" $1
docker run --name nginx.$1 --network=web  -l traefik.frontend.rule=Host:$1 -v $PWD/html:/var/www/html:ro -v $PWD/default.conf:/etc/nginx/conf.d/default.conf -v $PWD/error.log:/var/log/nginx/error.log -d nginx
echo "Instalando nginx para" $1
docker run --name php72.$1 --network=web  -v $PWD/html:/var/www/html:ro -d php:7.2-fpm-stretch


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
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_param PATH_INFO \$fastcgi_path_info;
    }
}
EOF


#sed -i 's/localhost:9000/'$(docker ps -aqf 'name=php72.'$1)':9000/g' default.conf

sleep 3

docker restart php72.$1 nginx.$1


docker inspect nginx.$1 |grep IPAddress
