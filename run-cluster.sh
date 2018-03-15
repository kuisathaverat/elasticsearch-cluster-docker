#!/bin/sh
#      -v "$PWD/data/node01":/usr/share/elasticsearch/data:rw\
#

PWD=$(pwd)
NET=172.18.0.0/24
NODE01=172.18.0.10
NODE02=172.18.0.11
NODE03=172.18.0.12
NODE_NGINX=172.18.0.13

mkdir -p ${PWD}/data/node01
mkdir -p ${PWD}/data/node02
mkdir -p ${PWD}/data/node03
mkdir -p ${PWD}/nginx/log

docker stop ESNode01 ESNode02 ESNode03 ESNginx
docker rm ESNode01 ESNode02 ESNode03 ESNginx

docker network create --subnet=${NET} esNetwork
docker pull elasticsearch:1.7.6-alpine
docker pull nginx

docker run -d --name "ESNginx"\
  -v $(pwd)/nginx/conf.d:/etc/nginx/conf.d\
  -v $(pwd)/nginx/log:/var/log/nginx\
  -h nginx\
  --add-host node01:$NODE01\
  --add-host node02:$NODE02\
  --add-host node03:$NODE03\
  --add-host nginx:$NODE_NGINX\
  --net esNetwork\
  --ip $NODE_NGINX\
  -p 9200:9200\
  -t nginx

docker run -d --name "ESNode01"\
  -v "$PWD/config":/usr/share/elasticsearch/config:rw\
  -v "$PWD/data/node01":/usr/share/elasticsearch/data:rw\
  -h node01\
  --add-host node01:$NODE01\
  --add-host node02:$NODE02\
  --add-host node03:$NODE03\
  --net esNetwork\
  --ip $NODE01\
  elasticsearch:1.7.6-alpine -Des.node.name="node01"

docker run -d --name "ESNode02"\
  -v "$PWD/config":/usr/share/elasticsearch/config:rw\
  -v "$PWD/data/node02":/usr/share/elasticsearch/data:rw\
  -h node02\
  --add-host node01:$NODE01\
  --add-host node02:$NODE02\
  --add-host node03:$NODE03\
  --net esNetwork\
  --ip $NODE02\
  elasticsearch:1.7.6-alpine -Des.node.name="node02"

docker run -d --name "ESNode03"\
  -v "$PWD/config":/usr/share/elasticsearch/config:rw\
  -v "$PWD/data/node03":/usr/share/elasticsearch/data:rw\
  -h node03\
  --add-host node01:$NODE01\
  --add-host node02:$NODE02\
  --add-host node03:$NODE03\
  --net esNetwork\
  --ip $NODE03\
  elasticsearch:1.7.6-alpine -Des.node.name="node03"
