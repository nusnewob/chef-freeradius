#
# Cookbook Name:: freeradius
# Recipe:: package
#
# Copyright 2011, Hexa
#
# All rights reserved - Do Not Redistribute
#

case node['platform']
when 'ubuntu'
  apt_repository 'freeradius-repo' do
    uri node['freeradius']['repo']
    distribution node['lsb']['codename']
    components ['main']
  end
end

node['freeradius']['pkgs'].each do |pkg|
  package pkg do
    action :install
  end
end

if node['freeradius']['enable_ldap'] == true
  node['freeradius']['ldap_pkgs'].each do |pkg|
    package pkg do
      action :install
    end
  end
end
