#!/bin/sh

docker rm -f traccar mariadb-traccar

mkdir -p /docker/traccar/logs
mkdir -p /docker/traccar/db

cat <<EOF > /docker/traccar/traccar.xml
<?xml version='1.0' encoding='UTF-8'?>

<!DOCTYPE properties SYSTEM 'http://java.sun.com/dtd/properties.dtd'>

<properties>

    <entry key='config.default'>./conf/default.xml</entry>

    <!--

    This is the main configuration file. All your configuration parameters should be placed in this file.

    Default configuration parameters are located in the "default.xml" file. You should not modify it to avoid issues
    with upgrading to a new version. Parameters in the main config file override values in the default file. Do not
    remove "config.default" parameter from this file unless you know what you are doing.

    For list of available parameters see following page: https://www.traccar.org/configuration-file/

    -->

    <entry key='database.driver'>com.mysql.jdbc.Driver</entry>
    <entry key='database.url'>jdbc:mysql://mariadb-traccar:3306/db_traccar?useSSL=false&amp;allowMultiQueries=true&amp;autoReconnect=true&amp;useUnicode=yes&amp;characterEncoding=UTF-8&amp;sessionVariables=sql_mode=''</entry>
    <entry key='database.user'>root</entry>
    <entry key='database.password'>traccar</entry>

</properties>
EOF


docker network create traccar

#docker run --rm --entrypoint cat traccar/traccar:4.0 /opt/traccar/conf/traccar.xml > /docker/traccar/traccar.xml

docker run --name mariadb-traccar  --network=traccar -v /docker/traccar/db:/var/lib/mysql --restart unless-stopped -e MYSQL_ROOT_PASSWORD=traccar -e MYSQL_DATABASE=db_traccar -d mariadb

#docker run --name myadmin -d --network=traccar -e PMA_HOST=mariadb-traccar -p 81:80 phpmyadmin/phpmyadmin

docker run \
 --restart unless-stopped \
 --name traccar \
 --hostname traccar \
 --network=traccar \
 -p 8082:8082 \
 -p 5000-5035:5000-5035 \
 -p 5000-5035:5000-5035/udp \
 -p 5037:5037 \
 -p 5037:5037/udp \
 -p 5039-5059:5039-5059 \
 -p 5039-5059:5039-5059/udp \
 -p 5062-5150:5062-5150 \
 -p 5062-5150:5062-5150/udp \
 -v /docker/traccar/logs:/opt/traccar/logs:rw \
 -v /docker/traccar/traccar.xml:/opt/traccar/conf/traccar.xml:ro \
 -d traccar/traccar:4.0







