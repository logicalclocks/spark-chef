#
# Cookbook Name:: spark
# Recipe:: install
#
# Copyright 2015, Jim Dowling
#
# All rights reserved
#

group node[:spark][:group] do
  action :create
end

user node[:spark][:user] do
  supports :manage_home => true
  home "/home/#{node[:spark][:user]}"
  action :create
  system true
  shell "/bin/bash"
  not_if "getent passwd #{node[:spark]['user']}"
end

group node[:spark][:group] do
  action :modify
  members ["#{node[:spark][:user]}"]
  append true
end


for p in %w{ git scala }
  package p do
    action :install
  end
end

package_url = "#{node[:spark][:url]}"
base_package_filename = File.basename(package_url)
cached_package_filename = "#{Chef::Config[:file_cache_path]}/#{base_package_filename}"

remote_file cached_package_filename do
  source package_url
  owner "root"
  mode "0644"
  action :create_if_missing
end

# Extract Spark
bash 'extract-spark' do
        user "root"
        code <<-EOH
                tar -xf #{cached_package_filename} -C #{node[:spark][:dir]}
                chown -R #{node[:spark][:user]}:#{node[:spark][:group]} #{node[:spark][:home]}
                touch #{node[:spark][:dir]}/.spark_extracted_#{node[:spark][:version]}
                chown #{node[:spark][:user]} #{node[:spark][:dir]}/.spark_extracted_#{node[:spark][:version]}
        EOH
     not_if { ::File.exists?( "#{node[:spark][:dir]}/.spark_extracted_#{node[:spark][:version]}" ) }
end


template"#{node[:spark][:home]}/conf/log4j.properties" do
  source "log4j.properties.erb"
  owner node[:spark][:user]
  group node[:spark][:group]
  mode 0655
end

link node[:spark][:base_dir] do
  owner node[:spark][:user]
  group node[:spark][:group]
  to node[:spark][:home]
end


libpath = File.expand_path '../../../kagent/libraries', __FILE__
require File.join(libpath, 'inifile')

my_ip = my_private_ip()
master_ip = private_recipe_ip("spark","master")
namenode_ip = private_recipe_ip("hadoop","nn")

template"#{node[:spark][:home]}/conf/spark-env.sh" do
  source "spark-env.sh.erb"
  owner node[:spark][:user]
  group node[:spark][:group]
  mode 0655
  variables({ 
        :private_ip => my_ip,
        :master_ip => master_ip,
        :spark_assembly => "hdfs://#{namenode_ip}:#{node[:hadoop][:nn][:port]}/user/#{node[:spark][:user]}/share/lib/spark-assembly.jar"
           })
end


template"#{node[:spark][:home]}/conf/spark-defaults.conf" do
  source "spark-defaults.conf.erb"
  owner node[:spark][:user]
  group node[:spark][:group]
  mode 0655
  variables({ 
        :private_ip => my_ip,
        :namenode_ip => namenode_ip,
        :master_ip => master_ip
           })
end

