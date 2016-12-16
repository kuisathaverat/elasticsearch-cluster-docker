#!/bin/sh
#      -v "$PWD/data/node01":/usr/share/elasticsearch/data:rw\   
#    

PWD=$(pwd)
docker network create --subnet=172.18.0.0/24 esNetwork
docker pull elasticsearch:1.7.6-alpine
docker run -d --name "ESNode01"\
    -v "$PWD/config":/usr/share/elasticsearch/config:rw\
    --net esNetwork --ip 172.18.0.10 -p 9200:9200 -p 9300:9300\
    elasticsearch:1.7.6-alpine -Des.node.name="ESNode01"

docker run -d --name "ESNode02"\
    -v "$PWD/config":/usr/share/elasticsearch/config:rw\
    --net esNetwork --ip 172.18.0.11 -P\
    elasticsearch:1.7.6-alpine -Des.node.name="ESNode02"

docker run -d --name "ESNode03"\
    -v "$PWD/config":/usr/share/elasticsearch/config:rw\
    --net esNetwork --ip 172.18.0.12 -P\
    elasticsearch:1.7.6-alpine -Des.node.name="ESNode03"
