# PHP-FPM with Nginx

### Installed packages

- nginx
- curl
- supervisord
- php 5.6 [fpm, cli, dev, memcached, pear, xsl, curl]
- openjdk
- ant
- phing

### Development workflow

> !Important :: You must have a debian wheezy image installed.

======

Check if already have a wheezy image:

```
docker images -a | grep wheezy | awk '{print $3}'
```

If grep return a null result, download it by command:
```
docker pull debian:wheezy
```

======

#### Config env as container -

======

Build a new container from wheezy image:
```
docker create --name env_docker_dft -it $(docker images -a | grep wheezy | awk '{print $3}') bash
```

Start container:
```
docker start env_docker_dft
```

Access container terminal:
```
docker exec -it env_docker_dft bash
```

Stop container:
```
docker stop env_docker_dft
```

Remove container:
```
docker rm -f env_docker_dft
```

#### Building -

```
docker build ./ --tag dafiti:dafiti_docker_stack
```