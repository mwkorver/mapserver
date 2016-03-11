# Mapserver for Docker, with Nginx, for demo testing only
FROM ubuntu:trusty
MAINTAINER Mark Korver<mwkorver@gmail.com>

ENV LANG C.UTF-8
RUN update-locale LANG=C.UTF-8

# Install mapserver compilation prerequisites
RUN apt-get update && \
    DEBIAN_FRONTEND="noninteractive" && \
    apt-get install -y --no-install-recommends \
    software-properties-common \
    g++ \
    make \
    cmake \
    wget \
    git \
    openssh-server \
    libxml2-dev \
    libxslt1-dev \
    libproj-dev \
    libfribidi-dev \
    libcairo2-dev \
    librsvg2-dev \
    libmysqlclient-dev \
    libpq-dev \
    libcurl4-gnutls-dev \
    libexempi-dev \
    libgdal-dev \
    libgeos-dev \
    libfcgi-dev 

# Install libharfbuzz from source as it is not in a repository
RUN cd /tmp && wget http://www.freedesktop.org/software/harfbuzz/release/harfbuzz-0.9.19.tar.bz2 && \
    tar xjf harfbuzz-0.9.19.tar.bz2 && \
    cd harfbuzz-0.9.19 && \
    ./configure && \
    make && \
    make install && \
    ldconfig

# Install Mapserver itself
RUN git clone https://github.com/mapserver/mapserver/ /usr/local/src/mapserver

# Compile Mapserver
RUN mkdir /usr/local/src/mapserver/build && \
    cd /usr/local/src/mapserver/build && \
    cmake ../ -DWITH_THREAD_SAFETY=1 \
        -DWITH_PROJ=1 \
        -DWITH_KML=1 \
        -DWITH_SOS=1 \
        -DWITH_WMS=1 \
        -DWITH_FRIBIDI=1 \
        -DWITH_HARFBUZZ=1 \
        -DWITH_ICONV=1 \
        -DWITH_CAIRO=1 \
        -DWITH_RSVG=1 \
        -DWITH_MYSQL=1 \
        -DWITH_GEOS=1 \
        -DWITH_POSTGIS=1 \
        -DWITH_GDAL=1 \
        -DWITH_OGR=1 \
        -DWITH_CURL=1 \
        -DWITH_CLIENT_WMS=1 \
        -DWITH_CLIENT_WFS=1 \
        -DWITH_WFS=1 \
        -DWITH_WCS=1 \
        -DWITH_LIBXML2=1 \
        -DWITH_GIF=1 \
        -DWITH_EXEMPI=1 \
        -DWITH_XMLMAPFILE=1 \
        -DWITH_FCGI=1 && \
    make && \
    make install && \
    ldconfig

# Copy mapserver service
COPY etc/mapserver /etc/init.d/mapserver
RUN chmod +x /etc/init.d/mapserver

# Link to cgi-bin executable
RUN chmod o+x /usr/local/bin/mapserv  && \
    mkdir -p /usr/lib/cgi-bin && \
    ln -s /usr/local/bin/mapserv /usr/lib/cgi-bin/mapserv && \
    chmod 755 /usr/lib/cgi-bin

# Install supervisor and spawn-fcgi
RUN apt-get install -y supervisor spawn-fcgi && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /var/log/supervisor

COPY etc/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Install Nginx
ENV NGINX_VERSION=1.8.1 
RUN apt-key adv --fetch-keys http://nginx.org/keys/nginx_signing.key && \
    echo "deb http://nginx.org/packages/ubuntu/ trusty nginx" >> /etc/apt/sources.list.d/nginx-trusty.list && \
    apt-get update && \
    apt-get install nginx=${NGINX_VERSION}* && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean && \
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

# Copy Nginx config 
COPY etc/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 22 8080

WORKDIR /etc/nginx

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
