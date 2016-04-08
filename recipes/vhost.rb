template "#{node['freeradius']['dir']}/sites-available/default" do
  source "site-default.erb"
  owner node['freeradius']['user']
  group node['freeradius']['group']
  mode 0600
  notifies :restart, "service[#{node['freeradius']['service']}]", :immediately
end

template "#{node['freeradius']['dir']}/sites-available/inner-tunnel" do
  source "site-inner-tunnel.erb"
  owner node['freeradius']['user']
  group node['freeradius']['group']
  mode 0600
  notifies :restart, "service[#{node['freeradius']['service']}]", :immediately
end
