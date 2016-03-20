#
# Cookbook Name:: freeradius
# Recipe:: default
#
# Copyright 2012, NM Consulting
#
# All rights reserved - Do Not Redistribute
#
include_recipe "freeradius::#{node[:freeradius][:install_method]}"

user_auth = Chef::EncryptedDataBagItem.load(node['freeradius']['db_databag'], node['freeradius']['db_databag_item'])
user_auth.each do |user, passwd|
  node.override['freeradius']['db_login'] = user
  node.override['freeradius']['db_password'] = passwd
end

if node['freeradius']['enable_ldap'] == true
  include_recipe "freeradius::ldap"
end

if node['freeradius']['enable_sql'] == true
  include_recipe "freeradius::sql"
end

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

include_recipe "freeradius::vhost"
