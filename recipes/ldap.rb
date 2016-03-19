template "#{node['freeradius']['dir']}/mods-available/ldap" do
  source "ldap.erb"
  owner node['freeradius']['user']
  group node['freeradius']['group']
  mode 0600
end

link "#{node['freeradius']['dir']}/mods-enabled/ldap" do
  to "#{node['freeradius']['dir']}/mods-available/ldap"
  notifies :restart, "service[#{node['freeradius']['service']}]", :immediately
end
