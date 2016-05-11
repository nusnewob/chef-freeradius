template "#{node['freeradius']['dir']}/sites-available/default" do
  source "site-default.erb"
  owner node['freeradius']['user']
  group node['freeradius']['group']
  mode 0600
end

template "#{node['freeradius']['dir']}/sites-available/inner-tunnel" do
  source "site-inner-tunnel.erb"
  owner node['freeradius']['user']
  group node['freeradius']['group']
  mode 0600
end

template "#{node['freeradius']['dir']}/sites-available/status" do
  source "site-status.erb"
  owner node['freeradius']['user']
  group node['freeradius']['group']
  mode 0600
end

link "#{node['freeradius']['dir']}/sites-enabled/default" do
  to "#{node['freeradius']['dir']}/sites-available/default"
  notifies :restart, "service[#{node['freeradius']['service']}]", :immediately
end

link "#{node['freeradius']['dir']}/sites-enabled/inner-tunnel" do
  to "#{node['freeradius']['dir']}/sites-available/inner-tunnel"
  notifies :restart, "service[#{node['freeradius']['service']}]", :immediately
end

link "#{node['freeradius']['dir']}/sites-enabled/status" do
  to "#{node['freeradius']['dir']}/sites-available/status"
  notifies :restart, "service[#{node['freeradius']['service']}]", :immediately
end
