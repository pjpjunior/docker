FROM centos:7

#docker build -t localhost/asterisk:11 .
#docker run -it --name=asterisk11 -v /docker/asterisk11/etc/:/etc/asterisk/ localhost/asterisk:11

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
&& chown -R asterisk:asterisk /etc/asterisk

CMD /usr/sbin/asterisk -f -U asterisk -G asterisk -vvvg -c
