FROM ubuntu:18.04 AS bluecherry
MAINTAINER chall@corp.bluecherry.net
WORKDIR /root

ENV DEBIAN_FRONTEND=noninteractive
ENV MYSQL_ADMIN_LOGIN=root
ENV MYSQL_ADMIN_PASSWORD=pwdForMySQLvErYsEcReT
ENV dbname=bluecherry
ENV host=mysql
ENV userhost=%
ENV user=bluecherry
ENV password=pwdForMySQLvErYsEcReT
ENV BLUECHERRY_GROUP_ID=1000
ENV BLUECHERRY_USER_ID=1000

RUN /usr/sbin/groupadd -r -f -g $BLUECHERRY_GROUP_ID bluecherry && \
    useradd -c "Bluecherry DVR" -d /var/lib/bluecherry -g bluecherry -G audio,video -r -m bluecherry -u $BLUECHERRY_USER_ID && \
    { \
        echo "[client]";                        \
        echo "user=$MYSQL_ADMIN_LOGIN";         \
        echo "password=$MYSQL_ADMIN_PASSWORD";  \
        echo "[mysql]";                         \
        echo "user=$MYSQL_ADMIN_LOGIN";         \
        echo "password=$MYSQL_ADMIN_PASSWORD";  \
        echo "[mysqldump]";                     \
        echo "user=$MYSQL_ADMIN_LOGIN";         \
        echo "password=$MYSQL_ADMIN_PASSWORD";  \
        echo "[mysqldiff]";                     \
        echo "user=$MYSQL_ADMIN_LOGIN";         \
        echo "password=$MYSQL_ADMIN_PASSWORD";  \
    } > /root/.my.cnf                           && \
    apt-get update                              && \
    { \
        echo bluecherry bluecherry/mysql_admin_login password $MYSQL_ADMIN_LOGIN;       \
        echo bluecherry bluecherry/mysql_admin_password password $MYSQL_ADMIN_PASSWORD; \
        echo bluecherry bluecherry/db_host string $host;                                \
        echo bluecherry bluecherry/db_userhost string $userhost;                        \
        echo bluecherry bluecherry/db_name string $dbname;                              \
        echo bluecherry bluecherry/db_user string $user;                                \
        echo bluecherry bluecherry/db_password password $password;                      \
    } | debconf-set-selections  && \
    apt -y install wget gnupg supervisor && \
    apt --no-install-recommends -y install rsyslog mysql-client
RUN wget -q https://dl.bluecherrydvr.com/key/bluecherry.asc && \
    apt-key add bluecherry.asc && \
    wget --no-check-certificate --output-document=/etc/apt/sources.list.d/bluecherry-bionic.list https://dl.bluecherrydvr.com/sources.list.d/bluecherry-bionic-unstable.list && \
    apt-get update
RUN apt --no-install-recommends -y bluecherry || exit 0

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN mkdir -p /var/lib/bluecherry/recordings && \
	chmod 770 /var/lib/bluecherry/recordings && \
    chown bluecherry.bluecherry /var/lib/bluecherry/recordings 

CMD ["/usr/bin/supervisord"]
