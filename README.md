# MapServer

This is UMN MapServer behind Nginx using FastCGI in a Docker container.
The goal of this project is to simplify the instantiation of a WMS service able to serve a large collection of orthoimagery. 
This repo is based on srounet/docker-mapserver. I have swapped out Apache with Nginx, and taken out PHP. You could use the same general pattern to serve WFS by running this container on top of a number of PostgreSQL read-replicas running on Amazon RDS.

## UMN Mapserver

MapServer is an Open Source platform for publishing spatial data and interactive mapping applications to the web. Originally developed in the mid-1990’s at the University of Minnesota, MapServer is released under an MIT-style license, and runs on all major platforms (Windows, Linux, Mac OS X). MapServer is not a full-featured GIS system, nor does it aspire to be.
See https://github.com/mapserver/mapserver 

## Building mapserver

Running this will build a docker image with mapserver 7

    git clone https://github.com/mwkorver/mapserver
    cd mapserver
    docker build -t mapserver .

## Running docker-mapserver

This image expose two ports 22 for ssh and 80 for Mapserver

    docker run -d -p 80:8080 -v /usr/local/mapserver:/maps --name mapserver mapserver

## Test it

wget -qO- h http://HOST_IP/wms

You should get something like this:
No query information to decode. QUERY_STRING is set, but empty. 
