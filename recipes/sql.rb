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

require 'mysql2'
mysql_connection_info = {
  :host => node['freeradius']['db_server'],
  :port => node['freeradius']['db_port'],
  :username => node['freeradius']['db_login'],
  :password => node['freeradius']['db_password'],
  :flags => (Mysql2::Client.default_query_options[:connect_flags] |= Mysql2::Client::MULTI_STATEMENTS)
}

unless node['freeradius']['db_configured']
  node['freeradius']['db_schemas'].each do |sql|
    mysql_database node['freeradius']['db_name'] do
      connection mysql_connection_info
      database_name node['freeradius']['db_name']
      sql { ::File.open(sql).read }
      action :query
    end
  end
end

ruby_block "set freeradius database configured flag" do
  block do
    node.set['freeradius']['db_configured'] = true
  end
end
