FROM centos:7

#docker build -t pjpjunior/asterisk:13 . && docker push pjpjunior/asterisk:13
#docker run -it --rm pjpjunior/asterisk:13
#docker run -it --name=asterisk13 -p 5060:5060/udp -p 10000-10098:10000-10098/udp -v /docker/asterisk13/asterisk/:/etc/asterisk/ -v /docker/asterisk13/pt_br:/var/lib/asterisk/sounds/pt_br -v /docker/asterisk13/moh:/var/lib/asterisk/moh pjpjunior/asterisk:13

#5036/udp 5038/tcp 5038/udp 

WORKDIR /etc/asterisk/

RUN yum update -y && yum install -y \
  make \
  wget \
  openssl-devel \
  ncurses-devel \
  newt-devel \
  libxml2-devel \
  kernel-devel \
  gcc \
  gcc-c++ \
  sqlite-devel \
  libuuid-devel \
  mpg123 \
  sox \
  git \
  vi \
&& yum clean all 


RUN cd /usr/src/ && git clone -b 13 http://gerrit.asterisk.org/asterisk asterisk-13 \
&& cd asterisk-13 \
&& ./configure --libdir=/usr/lib64 \
&& make menuselect.makeopts \
&& menuselect/menuselect \
  --disable BUILD_NATIVE \
  --enable cdr_csv \
  --enable chan_sip \
  --enable res_snmp \
  --enable res_http_websocket \
  --enable res_hep_pjsip \
  --enable res_hep_rtcp \
  menuselect.makeopts \
&& make \
&& make install \
&& make samples \
&& make clean \
&& make distclean \
&& useradd -m asterisk -s /sbin/nologin \
&& chown -R asterisk:asterisk /var/lib/asterisk/ \
&& chown -R asterisk:asterisk /var/spool/asterisk/ \
&& chown -R asterisk:asterisk /var/log/asterisk/ \
&& chown -R asterisk:asterisk /var/run/asterisk/ \
&& chown -R asterisk:asterisk /usr/sbin/asterisk \
&& chown -R asterisk:asterisk /var/lib/asterisk/sounds/ \
&& chown -R asterisk:asterisk /etc/asterisk/



CMD asterisk -fvvvv
