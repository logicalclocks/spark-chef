
my_ip = my_private_ip()
my_public_ip = my_public_ip()

eventlog_dir =
  if node.hadoop_spark.key?('.eventlog.dir')
    "#{node.hadoop_spark.eventlog.dir}"
  else
    "#{node.apache_hadoop.hdfs.user_home}/#{node.hadoop_spark.user}/applicationHistory"
  end

tmp_dirs   = ["#{node.apache_hadoop.hdfs.user_home}/#{node.hadoop_spark.user}", eventlog_dir ]
for d in tmp_dirs
 apache_hadoop_hdfs_directory d do
    action :create
    owner node.hadoop_spark.user
    group node.hadoop_spark.group
    mode "1777"
    not_if ". #{node.apache_hadoop.home}/sbin/set-env.sh && #{node.apache_hadoop.home}/bin/hdfs dfs -test -d #{d}"
  end
end


case node.platform
when "ubuntu"
 if node.platform_version.to_f <= 14.04
   node.override.hadoop_spark.systemd = "false"
 end
end


service_name="spark-history-server"

if node.hadoop_spark.systemd == "true"

  service service_name do
    provider Chef::Provider::Service::Systemd
    supports :restart => true, :stop => true, :start => true, :status => true
    action :nothing
  end

  case node.platform_family
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

  directory "/etc/systemd/system/#{service_name}.service.d" do
    owner "root"
    group "root"
    mode "755"
    action :create
    recursive true
  end

  template "/etc/systemd/system/#{service_name}.service.d/limits.conf" do
    source "limits.conf.erb"
    owner "root"
    mode 0774
    action :create
  end 

  hadoop_spark_start "reload_spark_historyserver" do
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
    owner node.hadoop_spark.yarn.user
    group node.hadoop_spark.group
    mode 0754
    notifies :enable, resources(:service => service_name)
    notifies :restart, resources(:service => service_name), :immediately
  end

end


if node.kagent.enabled == "true" 
  # kagent_config service_name do
  #   service "YARN"
  #   start_script "service spark-history-server start"
  #   stop_script "service spark-history-server stop"
  #   log_file "#{node.hadoop_spark.logs_dir}/historyserver.log"
  #   pid_file "/tmp/spark-history-server.pid"
  #   web_port 8080
  # end
end



