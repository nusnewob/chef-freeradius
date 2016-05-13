template "#{node['freeradius']['dir']}/mods-available/counter" do
  source "mod-counter.erb"
  owner node['freeradius']['user']
  group node['freeradius']['group']
  mode 0600
end

link "#{node['freeradius']['dir']}/mods-enabled/counter" do
  to "#{node['freeradius']['dir']}/mods-available/counter"
  notifies :restart, "service[#{node['freeradius']['service']}]", :immediately
end
