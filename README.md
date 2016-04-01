This is UMN MapServer (http://www.mapserver.org/) using Nginx setup with FastCGI as a Docker image.
The goal of this project is to simplify the instantiation of a WMS service able to serve a large collection of orthoimagery. 
This repo is based on srounet/docker-mapserver. I have swapped out Apache with Nginx, and taken out PHP. You could use the same general pattern to serve WFS by running this container on top of a number of PostgreSQL read-replicas running on Amazon RDS.
Use this in combination with Amazon EC2 user data script below that runs the container on an instance that uses yas3fs to mount USDA NAIP data on Amazon S3.

https://gist.github.com/mwkorver/1ef45abac3871360f2b1

## UMN Mapserver

MapServer is an Open Source platform for publishing spatial data and interactive mapping applications to the web. Originally developed in the mid-1990’s at the University of Minnesota, MapServer is released under an MIT-style license, and runs on all major platforms (Windows, Linux, Mac OS X). 
See http://www.mapserver.org/

## Building 

Running this will build a docker image with mapserver 7

    git clone https://github.com/mwkorver/mapserver
    cd mapserver
    docker build -t mapserver .

## Running 

This image exposes two ports 22 for ssh and 8080 for Nginx

    docker run -d -p 80:8080 -v /usr/local/mapserver:/maps --name mapserver mapserver

## Testing

wget -qO- h http://HOST_IP/wms

You should get something like this:
No query information to decode. QUERY_STRING is set, but empty. 
