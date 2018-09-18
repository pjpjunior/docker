FROM centos:7

#docker build -t localhost/asterisk:11 .
#docker run -it --rm pjpjunior/asterisk:11
#docker run -it --name=asterisk11 -p 5060:5060/udp -p 10000-10098:10000-10098/udp -v /docker/asterisk11/etc/:/etc/asterisk/ -v /docker/asterisk11/pt_br:/var/lib/asterisk/sounds/pt_br -v /docker/asterisk11/moh:/var/lib/asterisk/moh pjpjunior/asterisk:11

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


RUN cd /usr/src/ && git clone -b 11 http://gerrit.asterisk.org/asterisk asterisk-11 \
&& cd asterisk-11 \
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
&& useradd -m asterisk -s /sbin/nologin

CMD asterisk -fvvvv
