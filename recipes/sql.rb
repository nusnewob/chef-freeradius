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

user_auth = Chef::EncryptedDataBagItem.load("mysql", node['freeradius']['db_name'])
user_auth['mysql'].each do |user, passwd|
  mysql_connection_info = {
    :host => node['freeradius']['db_server'],
    :port => node['freeradius']['db_port'],
    :username => user,
    :password => passwd
  }
end

node['freeradius']['db_schemas'].each do |sql|
  mysql_database node['freeradius']['db_name'] do
    connection mysql_connection_info
    sql "source #{sql};"
  end
end
