FROM xrootd_base

RUN chef-client -z -o /cookbooks/alicet2_xrootd/recipes/default.rb
RUN chef-client -z -o /cookbooks/alicet2_xrootd/recipes/fix_ownership.rb
