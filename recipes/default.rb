#
# Cookbook Name:: freeradius
# Recipe:: default
#
# Copyright 2012, NM Consulting
#
# All rights reserved - Do Not Redistribute
#
include_recipe "freeradius::#{node[:freeradius][:install_method]}"

unless node['freeradius']['skip_db_passwords']
  user_auth = EncryptedPasswords.new(node, node['freeradius']['db_databag'])
  node.override['freeradius']['db_password'] = user_auth.find_password(node['freeradius']['db_databag_item'], node['freeradius']['db_login'])
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
