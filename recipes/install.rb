#
# Cookbook Name:: spark
# Recipe:: install
#
# Copyright 2015, Jim Dowling
#
# All rights reserved
#

include_recipe "java"
include_recipe "hops::wrap"

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

# Extract Spark
bash 'extract_hadoop_spark' do
        user "root"
        code <<-EOH
                tar -xf #{cached_package_filename} -C #{node.hadoop_spark.dir}
                chown -R #{node.hadoop_spark.user}:#{node.hadoop_spark.group} #{node.hadoop_spark.home}
                touch #{node.hadoop_spark.dir}/.hadoop_spark.extracted_#{node.hadoop_spark.version}
                chown #{node.hadoop_spark.user} #{node.hadoop_spark.dir}/.hadoop_spark.extracted_#{node.hadoop_spark.version}
        EOH
     not_if { ::File.exists?( "#{node.hadoop_spark.home}/.hadoop_spark.extracted_#{node.hadoop_spark.version}" ) }
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
        :private_ip => my_ip
           })
end


template"#{node.hadoop_spark.home}/conf/spark-defaults.conf" do
  source "spark-defaults.conf.erb"
  owner node.hadoop_spark.user
  group node.hadoop_spark.group
  mode 0655
  variables({ 
        :private_ip => my_ip,
        :namenode_ip => namenode_ip,
        :yarn => node.hadoop_spark.yarn.support
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


user_ulimit node.spark.user do
  filehandle_limit 65000
  process_limit 65000
  memory_limit 100000
  stack_soft_limit 65533
  stack_hard_limit 65533
end
