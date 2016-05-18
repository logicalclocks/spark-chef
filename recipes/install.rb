#
# Cookbook Name:: spark
# Recipe:: install
#
# Copyright 2015, Jim Dowling
#
# All rights reserved
#

include_recipe "java"

if node.hadoop_spark.hadoop.distribution === "hops"
 include_recipe "hops::wrap"
end
group node.hadoop_spark.group do
  action :create
end

user node.hadoop_spark.user do
  supports :manage_home => true
  home "/home/#{node.hadoop_spark.user}"
  action :create
  system true
  shell "/bin/bash"
  not_if "getent passwd #{node.hadoop_spark.user}"
end

group node.hadoop_spark.group do
  action :modify
   members ["#{node.hadoop_spark.user}"]
  append true
end

case node.platform_family
 when "debian"
  package "scala" do
    action :install
  end
 when "redhat"
  include_recipe "scala"
end


package_url = "#{node.hadoop_spark.url}"
base_package_filename = File.basename(package_url)
cached_package_filename = "#{Chef::Config.file_cache_path}/#{base_package_filename}"

remote_file cached_package_filename do
  source package_url
  owner "root"
  mode "0644"
  action :create_if_missing
end

spark_down = "#{node.hadoop_spark.dir}/.hadoop_spark.extracted_#{node.hadoop_spark.version}"
# Extract Spark
bash 'extract_hadoop_spark' do
        user "root"
        code <<-EOH
                tar -xf #{cached_package_filename} -C #{node.hadoop_spark.dir}
                chown -R #{node.hadoop_spark.user}:#{node.hadoop_spark.group} #{node.hadoop_spark.home}
                touch #{spark_down}
                chown #{node.hadoop_spark.user} #{node.hadoop_spark.dir}/.hadoop_spark.extracted_#{node.hadoop_spark.version}
                chown #{node.hadoop_spark.user} 
                touch #{spark_down}
        EOH
     not_if { ::File.exists?( spark_down ) }
end


template"#{node.hadoop_spark.home}/conf/log4j.properties" do
  source "log4j.properties.erb"
  owner node.hadoop_spark.user
  group node.hadoop_spark.group
  mode 0655
end

link node.hadoop_spark.base_dir do
  owner node.hadoop_spark.user
  group node.hadoop_spark.group
  to node.hadoop_spark.home
end


my_ip = my_private_ip()


if node.hadoop_spark.hadoop.distribution === "apache_hadoop"
 master_ip = private_recipe_ip("hadoop_spark","master")
 master_ip = "spark://#{master_ip}:#{node.hadoop_spark.master.port}"
else
 master_ip = "yarn"
end

begin
  namenode_ip = private_recipe_ip("hops","nn")
rescue
  namenode_ip = my_private_ip()
end

template"#{node.hadoop_spark.home}/conf/spark-env.sh" do
  source "spark-env.sh.erb"
  owner node.hadoop_spark.user
  group node.hadoop_spark.group
  mode 0655
  variables({ 
        :master_ip => master_ip,
        :private_ip => my_ip
           })
end


eventlog_dir = "#{node.apache_hadoop.hdfs.user_home}/#{node.hadoop_spark.user}/applicationHistory"
#  if node.hadoop_spark.key?('.eventlog.dir')
#    "#{node.hadoop_spark.eventlog.dir}"
#  else
#    "#{node.apache_hadoop.hdfs.user_home}/#{node.hadoop_spark.user}/applicationHistory"
#  end

begin
  historyserver_ip = private_recipe_ip("hadoop_spark","historyserver")
rescue
  historyserver_ip = my_private_ip()
end

template"#{node.hadoop_spark.home}/conf/spark-defaults.conf" do
  source "spark-defaults.conf.erb"
  owner node.hadoop_spark.user
  group node.hadoop_spark.group
  mode 0655
  variables({ 
        :private_ip => my_ip,
        :master_ip => master_ip,
        :namenode_ip => namenode_ip,
        :yarn => node.hadoop_spark.yarn.support,
        :eventlog_dir => eventlog_dir,
        :historyserver_ip => historyserver_ip
           })
end

file "#{node.hadoop_spark.home}/spark.jar" do
  action :delete
  force_unlink true  
end

link "#{node.hadoop_spark.home}/spark.jar" do
  owner node.hadoop_spark.user
  group node.hadoop_spark.group
  to "#{node.hadoop_spark.home}/lib/spark-assembly-#{node.hadoop_spark.version}-hadoop#{node.apache_hadoop.version}.jar"
end
