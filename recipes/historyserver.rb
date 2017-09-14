
my_ip = my_private_ip()
my_public_ip = my_public_ip()

eventlog_dir = "#{node['hops']['hdfs']['user_home']}/#{node['hadoop_spark']['user']}/applicationHistory"
tmp_dirs   = ["#{node['hops']['hdfs']['user_home']}/#{node['hadoop_spark']['user']}", eventlog_dir ]
for d in tmp_dirs
 hops_hdfs_directory d do
    action :create_as_superuser
    owner node['hadoop_spark']['user']
    group node['hadoop_spark']['group']
    mode "1777"
  end
end


case node['platform']
when "ubuntu"
 if node['platform_version'].to_f <= 14.04
   node.override['hadoop_spark']['systemd'] = "false"
 end
end

service_name="sparkhistoryserver"

if node['hadoop_spark']['systemd'] == "true"

  service service_name do
    provider Chef::Provider::Service::Systemd
    supports :restart => true, :stop => true, :start => true, :status => true
    action :nothing
  end

  case node['platform_family']
  when "rhel"
    systemd_script = "/usr/lib/systemd/system/#{service_name}.service"
  else
    systemd_script = "/lib/systemd/system/#{service_name}.service"
  end

  template systemd_script do
    source "#{service_name}.service.erb"
    owner "root"
    group "root"
    mode 0754
    notifies :enable, resources(:service => service_name)
    notifies :start, resources(:service => service_name), :immediately
  end

  kagent_config service_name do
    action :systemd_reload
  end

else #sysv

  service service_name do
    provider Chef::Provider::Service::Init::Debian
    supports :restart => true, :stop => true, :start => true, :status => true
    action :nothing
  end

  template "/etc/init.d/#{service_name}" do
    source "#{service_name}.erb"
    owner "root"
    group "root"
    mode 0754
    notifies :enable, resources(:service => service_name)
    notifies :restart, resources(:service => service_name), :immediately
  end

end


if node['kagent']['enabled'] == "true"
   kagent_config service_name do
     service service_name
     log_file "#{node['hadoop_spark']['base_dir']}/logs/spark-#{node['hadoop_spark']['user']}-org.apache.spark.deploy.history.HistoryServer-1-#{node['hostname']}.out"
     web_port node['hadoop_spark']['historyserver']['port']
   end
end

