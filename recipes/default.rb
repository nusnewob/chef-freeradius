#
# Cookbook Name:: freeradius
# Recipe:: default
#
# Copyright 2012, NM Consulting
#
# All rights reserved - Do Not Redistribute
#
include_recipe "freeradius::#{node[:freeradius][:install_method]}"

template "#{node['freeradius']['dir']}/clients.conf" do
  source "clients.conf.erb"
  owner node['freeradius']['user']
  group node['freeradius']['group']
  mode 0600
  notifies :restart, "service[#{node['freeradius']['service']}]", :immediately
end

template "#{node['freeradius']['dir']}/radiusd.conf" do
  source "radiusd.conf.erb"
  owner node['freeradius']['user']
  group node['freeradius']['group']
  mode 0600
  notifies :restart, "service[#{node['freeradius']['service']}]", :immediately
end

service node['freeradius']['service'] do
  supports :restart => true, :status => true, :reload => true
  action [:enable, :start]
end

if node['freeradius']['enable_ldap'] == true
  include_recipe "freeradius::ldap"
end

if node['freeradius']['enable_sql'] == true
  include_recipe "freeradius::sql"
end

if node['freeradius']['enable_counter'] == true
  include_recipe "freeradius::counter"
end

include_recipe "freeradius::vhost"

ruby_block "remove cleartext password from node attribute" do
  block do
    node.rm('freeradius', 'db_password')
    node.rm('freeradius', 'secret')
    node.rm('freeradius', 'clients')
  end
end
