# cicd-proyecto1

Repositorio para la sincronización de las instancias de Moodle. Aquí probamos varias formas de sincronizar las instancias.

El archivo [docker-compose.yml](docker-compose.yml) en el root del repositorio se encarga de hacer el siguiente despliegue:

![devops-V1](images/devops-V1.png)

En la carpeta "withs3" se monta la siguiente arquitectura:

![devops-V2](images/devops-V2.png)

Este despliegue fue implementado en el repositorio nuestro de Moodle: https://gitlab.com/anietog1/moodle_data

![devops-V3](images/devops-V3.png)

El archivo conf.sh hace un despliegue con la siguiente arquitectura:

![devops-V4](images/devops-V4.png)

Finalmente, lo que tenemos en producción es la segunda arquitectura debido a que hacer el mantenimiento del runner con el asunto de las credenciales es un proceso altamente tedioso.
