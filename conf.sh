#!/bin/bash -ex

if ! [ `whoami` = root ]; then
  sudo bash $0
  exit 0
fi

#
# setup environment
#

cd $HOME

# update and install
yum update -y
yum upgrade -y
yum install git docker -y

# install docker-compose
curl -L https://github.com/docker/compose/releases/download/1.25.4/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

# enable docker
systemctl start docker.service
systemctl enable docker.service

#
# setup moodle data
#

# cloning repository
DEPLOY_USERNAME=
DEPLOY_TOKEN=
GIT_PROVIDER=
GIT_USERNAME=
GIT_REPOSITORY=
git clone https://$DEPLOY_USERNAME:$DEPLOY_TOKEN@$GIT_PROVIDER/$GIT_USERNAME/$GIT_REPOSITORY.git

# setting up daemon
cat << EOF > /etc/systemd/system/gitpull.service
[Unit]
Description=git pull $GIT_REPOSITORY forever

[Service]
User=$USER
WorkingDirectory=$HOME/$GIT_REPOSITORY
ExecStart=/bin/git pull
Restart=always
RestartSec=300s

[Install]
WantedBy=multi-user.target
EOF

# starting daemon
systemctl start gitpull.service
systemctl enable gitpull.service

#
# setup docker image
#

MARIADB_HOST=
MARIADB_PORT_NUMBER=
MOODLE_DATABASE_USER=
MOODLE_DATABASE_NAME=
MOODLE_DATABASE_PASSWORD=
MOODLE_SKIP_INSTALL=

cat << EOF > docker-compose.yml
version: '2'
services:
  moodle:
    image: 'bitnami/moodle:3'
    environment:
      - MARIADB_HOST=$MARIADB_HOST
      - MARIADB_PORT_NUMBER=$MARIADB_PORT_NUMBER
      - MOODLE_DATABASE_USER=$MOODLE_DATABASE_USER
      - MOODLE_DATABASE_NAME=$MOODLE_DATABASE_NAME
      - MOODLE_DATABASE_PASSWORD=$MOODLE_DATABASE_PASSWORD
      - MOODLE_SKIP_INSTALL=$MOODLE_SKIP_INSTALL
    volumes:
      - './$GIT_REPOSITORY:/bitnami'
    ports:
      - '80:80'
      - '443:443'
    restart: always
EOF

docker-compose up -d
