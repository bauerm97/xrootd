## -*- docker-image-name: "xrootd_base" -*-
# xrootd base image. Provides the base image for each xrootd service
FROM debian:latest
MAINTAINER bauerm <bauerm@umich.edu>
RUN apt-get update
ADD https://packages.chef.io/stable/debian/8/chef_12.12.15-1_amd64.deb chef.deb
RUN dpkg -i chef.deb

ADD ./cookbooks/ /chef/cookbooks/
ADD ./roles/ /chef/roles/
ADD ./attributes/static.json /chef/attributes/
WORKDIR /chef
RUN chef-client --local -j /chef/attributes/static.json -o recipe[alicet2_xrootd::xrootd-service]
ONBUILD ADD ./ServiceRole.json /chef/roles/DefaultRole.json 
ONBUILD RUN chef-client --local -j /chef/attributes/static.json -o "role[DefaultRole]"
# ONBUILD RUN chef-client -z -o /cookbook/recipes/default.rb #If we only need to run one recipe per service, and it can use same name on each service we can use this line
