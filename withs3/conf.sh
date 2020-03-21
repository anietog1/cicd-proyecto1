#! /bin/bash

if ! [ `whoami` = root ]; then
  sudo bash $0
  exit 0
fi

#
# setup environment
#

HOME=/root
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
# setup docker image
#

MARIADB_HOST=
MARIADB_PORT_NUMBER=
MOODLE_DATABASE_NAME=
MOODLE_DATABASE_USER=
MOODLE_DATABASE_PASSWORD=
MOODLE_SKIP_INSTALL=

AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_SESSION_TOKEN=

BUCKET_NAME=
MOODLE_DATA_PATH=

cat << EOF > docker-compose.yml
version: '2'
services:
  moodle:
    image: bitnami/moodle:3
    container_name: moodle
    environment:
      - MARIADB_HOST=$MARIADB_HOST
      - MARIADB_PORT_NUMBER=$MARIADB_PORT_NUMBER
      - MOODLE_DATABASE_USER=$MOODLE_DATABASE_USER
      - MOODLE_DATABASE_NAME=$MOODLE_DATABASE_NAME
      - MOODLE_DATABASE_PASSWORD=$MOODLE_DATABASE_PASSWORD
      - MOODLE_SKIP_INSTALL=$MOODLE_SKIP_INSTALL
    volumes:
      - moodle_data:/bitnami
    ports:
      - 80:80
      - 443:443
    depends_on:
      - s3vol
    restart: always
  s3vol:
    image: elementar/s3-volume:latest
    container_name: s3vol
    environment:
      - AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
      - AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
      - AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN
      - BACKUP_INTERVAL=3m
    command: /data s3://$BUCKET_NAME/$MOODLE_DATA_PATH
    volumes:
      - moodle_data:/data
    restart: always
volumes:
  moodle_data:
    driver: local
EOF

docker-compose up -d
