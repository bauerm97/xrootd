FROM xrootd_base

ADD ./dynamic.json /chef/attributes/
RUN chef-client -j /chef/attributes/dynamic.json --local -o "role[redirector]"
