# Creating jenkins pipeline:
- building with teraform 2 VM on Yandex Cloud, "build" and "prod", and ansible inventory
- configure with ansible VMs
- build the project on "build" instance, build docker container and push to repo
- run Docker image on "prod" instance
