FROM ubuntu:16.04
MAINTAINER Tonny Gieselaar <tonny@devosverzuimbeheer.nl>

ENV DEBIAN_FRONTEND noninteractive

VOLUME ["/var/lib/samba", "/etc/samba"]

# Setup ssh and install supervisord
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y openssh-server supervisor net-tools nano apt-utils wget rsyslog
RUN mkdir -p /var/run/sshd
RUN mkdir -p /var/log/supervisor
RUN sed -ri 's/PermitRootLogin prohibit-password/PermitRootLogin Yes/g' /etc/ssh/sshd_config

# Install samba and dependencies to make it an Active Directory Domain Controller
RUN apt-get install -y build-essential libacl1-dev libattr1-dev \
      libblkid-dev libgnutls-dev libreadline-dev python-dev libpam0g-dev \
      python-dnspython gdb pkg-config libpopt-dev libldap2-dev \
      dnsutils libbsd-dev attr krb5-user docbook-xsl libcups2-dev acl python-xattr
RUN apt-get install -y samba smbclient krb5-kdc

# Install utilities needed for setup
RUN apt-get install -y expect pwgen
#ADD kdb5_util_create.expect kdb5_util_create.expect

# Set kerberos parameters
RUN rm /etc/krb5.conf && \
    ln -sf /var/lib/samba/private/krb5.conf /etc/krb5.conf

ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD init.sh /init.sh
RUN chmod 755 /init.sh
RUN apt-get clean
EXPOSE 22 53 389 88 135 139 138 445 464 3268 3269
ENTRYPOINT ["/init.sh"]
CMD ["app:start"]
