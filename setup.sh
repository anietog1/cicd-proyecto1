#! /bin/bash

docker-compose up -d

TOKEN= # insertar el token
PARAMS="--non-interactive --url https://gitlab.com/ --registration-token $TOKEN --executor shell"
while ! docker exec -it runner gitlab-runner register $PARAMS; do
    sleep 1
done

docker exec -it runner chown -R gitlab-runner:gitlab-runner /bitnami
