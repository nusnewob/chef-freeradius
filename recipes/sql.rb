if node['freeradius']['enable_sql'] == true
  node['freeradius']['sql_pkgs'].each do |pkg|
    package pkg do
      action :install
    end
  end
end

template "#{node['freeradius']['dir']}/mods-available/sql" do
  source "mod-sql.erb"
  owner node['freeradius']['user']
  group node['freeradius']['group']
  mode 0600
end

template "#{node['freeradius']['dir']}/mods-available/sqlcounter" do
  source "mod-sqlcounter.erb"
  owner node['freeradius']['user']
  group node['freeradius']['group']
  mode 0600
end

template "#{node['freeradius']['dir']}/mods-available/sqlippool" do
  source "mod-sqlippool.erb"
  owner node['freeradius']['user']
  group node['freeradius']['group']
  mode 0600
end

template "#{node['freeradius']['dir']}/mods-available/cui" do
  source "mod-cui.erb"
  owner node['freeradius']['user']
  group node['freeradius']['group']
  mode 0600
end

if ( node['freeradius']['run_sql'] && !(node['freeradius']['db_configured']) )

  mysql2_chef_gem 'default' do
    gem_version '0.4.3'
    action :install
  end

  chef_gem 'mysql2' do
    compile_time false
  end

  ruby_block "require mysql2" do
    block do
      require 'mysql2'
      node.run_state['mysql_flags'] = (Mysql2::Client.default_query_options[:connect_flags] |= Mysql2::Client::MULTI_STATEMENTS)
    end
  end

  mysql_connection_info = {
    :host => node['freeradius']['db_server'],
    :port => node['freeradius']['db_port'],
    :username => node['freeradius']['db_login'],
    :password => node['freeradius']['db_password'],
    :flags => node.run_state['mysql_flags']
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

end

link "#{node['freeradius']['dir']}/mods-enabled/sql" do
  to "#{node['freeradius']['dir']}/mods-available/sql"
  notifies :restart, "service[#{node['freeradius']['service']}]", :immediately
end

link "#{node['freeradius']['dir']}/mods-enabled/sqlcounter" do
  to "#{node['freeradius']['dir']}/mods-available/sqlcounter"
  notifies :restart, "service[#{node['freeradius']['service']}]", :immediately
end
link "#{node['freeradius']['dir']}/mods-enabled/sqlippool" do
  to "#{node['freeradius']['dir']}/mods-available/sqlippool"
  notifies :restart, "service[#{node['freeradius']['service']}]", :immediately
end
link "#{node['freeradius']['dir']}/mods-enabled/cui" do
  to "#{node['freeradius']['dir']}/mods-available/cui"
  notifies :restart, "service[#{node['freeradius']['service']}]", :immediately
end
