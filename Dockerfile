## -*- docker-image-name: "xrootd_base" -*-
# xrootd base image. Provides the base image for each xrootd service
FROM debian:8.5
MAINTAINER bauerm <bauerm@umich.edu>

ADD https://packages.chef.io/stable/debian/8/chef_12.12.15-1_amd64.deb chef.deb
RUN dpkg -i chef.deb

ONBUILD 
