template "#{node['freeradius']['dir']}/mods-available/sql" do
  source "sql.erb"
  owner node['freeradius']['user']
  group node['freeradius']['group']
  mode 0600
end

link "#{node['freeradius']['dir']}/mods-enabled/sql" do
  to "#{node['freeradius']['dir']}/mods-available/sql"
  notifies :restart, "service[#{node['freeradius']['service']}]", :immediately
end

mysql_connection_info = {
  :host => node['freeradius']['db_server'],
  :port => node['freeradius']['db_port'],
  :username => node['freeradius']['db_login'],
  :password => node['freeradius']['db_password']
}

node['freeradius']['db_schemas'].each do |sql|
  mysql_database node['freeradius']['db_name'] do
    connection mysql_connection_info
    database_name node['freeradius']['db_name']
    sql "source #{sql};"
  end
end
