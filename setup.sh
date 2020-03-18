#! /bin/bash

source .env

docker-compose up -d

PARAMS="--non-interactive --url https://gitlab.com/ --registration-token $REGISTRATION_TOKEN --executor shell"
while ! docker exec -it runner gitlab-runner register $PARAMS; do
    sleep 1
done

docker exec -it runner chown -R gitlab-runner:gitlab-runner /bitnami
docker exec -it runner bash -c 'cd /bitnami && git clone https://$DEPLOY_USERNAME:$DEPLOY_TOKEN@gitlab.com/$REPOSITORY.git'
