#!/bin/sh

mkdir -p /docker/asterisk11/pt_br
mkdir -p /docker/asterisk11/moh

docker run --rm -d --name=temp_asterisk pjpjunior/asterisk:11
docker cp temp_asterisk:/etc/asterisk/ /docker/asterisk11/
docker cp temp_asterisk:/var/lib/asterisk/moh/ /docker/asterisk11/
docker stop temp_asterisk

cd /docker/asterisk11/pt_br/

wget -O core.zip https://www.asterisksounds.org/pt-br/download/asterisk-sounds-core-pt-BR-sln16.zip
wget -O extra.zip https://www.asterisksounds.org/pt-br/download/asterisk-sounds-extra-pt-BR-sln16.zip

unzip -o core.zip
unzip -o extra.zip

rm -rf core.zip
rm -rf extra.zip

echo "Convertendo os arquivos"

for a in $(find . -name '*.sln16'); do
  sox -t raw -e signed-integer -b 16 -c 1 -r 16k $a -t raw -r 8k -e mu-law `echo $a|sed "s/.sln16/.ulaw/"`;\
done

########outras conversoes####################
# sox -t raw -e signed-integer -b 16 -c 1 -r 16k $a -t gsm -r 8k `echo $a|sed "s/.sln16/.gsm/"`;\
#  sox -t raw -e signed-integer -b 16 -c 1 -r 16k $a -t raw -r 8k -e a-law `echo $a|sed "s/.sln16/.alaw/"`;\

echo ""
echo ""
echo "######################"
echo "######################"
echo "########FIM###########"
echo "######################"
echo "######################"
echo "######################"

