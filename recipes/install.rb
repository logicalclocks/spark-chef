#
# Cookbook Name:: spark
# Recipe:: install
#
# Copyright 2015, Jim Dowling
#
# All rights reserved
#

include_recipe "java"

group node['hadoop_spark']['group'] do
  action :create
  not_if "getent group #{node['hadoop_spark']['group']}"
end

user node['hadoop_spark']['user'] do
  home "/home/#{node['hadoop_spark']['user']}"
  gid node['hadoop_spark']['group']
  action :create
  system true
  shell "/bin/bash"
  manage_home true
  not_if "getent passwd #{node['hadoop_spark']['user']}"
end

group node['hadoop_spark']['group'] do
  action :modify
   members ["#{node['hadoop_spark']['user']}"]
  append true
end

directory node['hadoop_spark']['dir']  do
  owner node['hadoop_spark']['user']
  group node['hadoop_spark']['group']
  mode "755"
  action :create
  not_if { File.directory?("#{node['hadoop_spark']['dir']}") }
end

package_url = "#{node['hadoop_spark']['url']}"
base_package_filename = File.basename(package_url)
cached_package_filename = "#{Chef::Config['file_cache_path']}/#{base_package_filename}"

remote_file cached_package_filename do
  source package_url
  owner "root"
  mode "0644"
  action :create_if_missing
end


package "zip" do
  action :install
end




spark_down = "#{node['hadoop_spark']['home']}/.hadoop_spark.extracted_#{node['hadoop_spark']['version']}"

# Extract Spark
bash 'extract_hadoop_spark' do
        user "root"
        code <<-EOH
                set -e
                rm -rf #{node['hadoop_spark']['base_dir']}
                tar -xf #{cached_package_filename} -C #{node['hadoop_spark']['dir']}
                touch #{spark_down}
        EOH
     not_if { ::File.exists?( spark_down ) }
end

#Copy SQL dependencies to SPARK_HOME/jars
purl=node['hadoop_spark']['spark_sql_dependencies_url']
# The following dependencies are required to run spark-sql with parquet and orc. We install them here so that users don't have to do it from their notebooks/jobs
# https://mvnrepository.com/artifact/org.spark-project.hive/hive-exec/1.2.1.spark2
# http://central.maven.org/maven2/org/iq80/snappy/snappy/0.4/
files= "parquet-encoding-#{node['hadoop_spark']['parquet_version']}.jar, parquet-common-#{node['hadoop_spark']['parquet_version']}.jar, parquet-hadoop-#{node['hadoop_spark']['parquet_version']}.jar, parquet-jackson-#{node['hadoop_spark']['parquet_version']}.jar, parquet-column-#{node['hadoop_spark']['parquet_version']}.jar, parquet-format-2.3.1.jar, hive-exec-1.2.1.spark2.jar, spark-hive_2.11-2.2.0.jar, snappy-0.4.jar"
allFiles = files.split(/\s*,\s*/)
  
for f in allFiles do

  remote_file "#{node['hadoop_spark']['home']}/jars/#{f}" do
    source "#{purl}/#{f}"
    owner node['hadoop_spark']['user']
    group node['hadoop_spark']['group']  
    mode "0644"
    action :create_if_missing
  end
  
end

link node['hadoop_spark']['base_dir'] do
  owner node['hadoop_spark']['user']
  group node['hadoop_spark']['group']
  to node['hadoop_spark']['home']
end

template"#{node['hadoop_spark']['conf_dir']}/log4j.properties" do
  source "log4j.properties.erb"
  owner node['hadoop_spark']['user']
  group node['hadoop_spark']['group']
  mode 0655
end

template"#{node['hadoop_spark']['conf_dir']}/yarnclient-driver-log4j.properties" do
  source "yarnclient-driver-log4j.properties.erb"
  owner node['hadoop_spark']['user']
  group node['hadoop_spark']['group']
  mode 0655
end

template"#{node['hadoop_spark']['conf_dir']}/executor-log4j.properties" do
  source "executor-log4j.properties.erb"
  owner node['hadoop_spark']['user']
  group node['hadoop_spark']['group']
  mode 0655
end


my_ip = my_private_ip()

master_ip = "yarn"

begin
  namenode_ip = private_recipe_ip("hops","nn")
rescue
  begin
    namenode_ip = private_recipe_ip("hops","nn")
  rescue
    namenode_ip = my_private_ip()
  end
end

template"#{node['hadoop_spark']['home']}/conf/spark-env.sh" do
  source "spark-env.sh.erb"
  owner node['hadoop_spark']['user']
  group node['hadoop_spark']['group']
  mode 0655
  variables({
        :master_ip => master_ip,
        :private_ip => my_ip
           })
end


eventlog_dir = "#{node['hops']['hdfs']['user_home']}/#{node['hadoop_spark']['user']}/applicationHistory"

begin
  historyserver_ip = private_recipe_ip("hadoop_spark","historyserver")
rescue
  historyserver_ip = my_private_ip()
end

template"#{node['hadoop_spark']['home']}/conf/spark-defaults.conf" do
  source "spark-defaults.conf.erb"
  owner node['hadoop_spark']['user']
  group node['hadoop_spark']['group']
  mode 0655
  variables({
        :private_ip => my_ip,
        :master_ip => master_ip,
        :namenode_ip => namenode_ip,
        :yarn => node['hadoop_spark']['yarn']['support'],
        :eventlog_dir => eventlog_dir,
        :historyserver_ip => historyserver_ip
           })
end

template"#{node['hadoop_spark']['home']}/conf/spark-blacklisted-properties.txt" do
  source "spark-blacklisted-properties.txt.erb"
  owner node['hadoop_spark']['user']
  group node['hadoop_spark']['group']
  mode 0655
end

magic_shell_environment 'SPARK_HOME' do
  value node['hadoop_spark']['base_dir']
end
