# Creating symbolic links from spark jars in the lib/ directory where spark is installed to 
# the directory containing yarn jars in hadoop. Hopefully, yarn will pick up these jars and add them
# to the HADOOP_CLASSPATH :)
# One potential problem could be if you install.hadoop_spark.as a different user than the default user 'yarn'.
# Then the symbolic link may not be able to be created due to a lack of file privileges.
# 

home = node.hops.hdfs.user_home
private_ip=my_private_ip()

hops_hdfs_directory "#{home}" do
  action :create_as_superuser
  owner node.hadoop_spark.user
  group node.hops.group
  mode "1777"
end


hops_hdfs_directory "#{home}/#{node.hadoop_spark.user}" do
  action :create_as_superuser
  owner node.hadoop_spark.user
  group node.hops.group
  mode "1777"
end

hops_hdfs_directory "#{home}/#{node.hadoop_spark.user}/eventlog" do
  action :create_as_superuser
  owner node.hadoop_spark.user
  group node.hops.group
  mode "1775"
end

hops_hdfs_directory "#{home}/#{node.hadoop_spark.user}/spark-warehouse" do
  action :create_as_superuser
  owner node.hadoop_spark.user
  group node.hops.group
  mode "1775"
end

hops_hdfs_directory "#{home}/#{node.hadoop_spark.user}/share/lib" do
  action :create_as_superuser
  owner node.hadoop_spark.user
  group node.hops.group
  mode "1775"
end

hops_hdfs_directory "#{node.hadoop_spark.home}/#{node.hadoop_spark.yarn.archive}" do
  action :put_as_superuser
  owner node.hadoop_spark.user
  group node.hops.group
  mode "1775"
  dest "#{node.hadoop_spark.yarn.archive_hdfs}"
end

hops_hdfs_directory "#{node.hadoop_spark.home}/python/lib/#{node.hadoop_spark.yarn.pyspark_archive}" do
  action :put_as_superuser
  owner node.hadoop_spark.user
  group node.hops.group
  mode "1775"
  dest "#{node.hadoop_spark.yarn.pyspark_archive_hdfs}"
end

hops_hdfs_directory "#{node.hadoop_spark.home}/python/lib/#{node.hadoop_spark.yarn.py4j_archive}" do
  action :put_as_superuser
  owner node.hadoop_spark.user
  group node.hops.group
  mode "1775"
  dest "#{node.hadoop_spark.yarn.py4j_archive_hdfs}"
end

#hops_hdfs_directory "#{node.hadoop_spark.home}/python/lib/#{node.hadoop_spark.yarn.python_tensorflow_archive}" do
#  action :put_as_superuser
#  owner node.hadoop_spark.user
#  group node.hops.group
#  mode "1775"
#  dest "#{node.hadoop_spark.yarn.python_tensorflow_archive_hdfs}"
#end

#hops_hdfs_directory "#{node.hadoop_spark.home}/python/lib/#{node.hadoop_spark.yarn.tfspark_archive}" do
#  action :put_as_superuser
#  owner node.hadoop_spark.user
#  group node.hops.group
#  mode "1775"
#  dest "#{node.hadoop_spark.yarn.tfspark_archive_hdfs}"
#end


# Add spark log4j.properties file to HDFS. Used by Logstash.

template "#{Chef::Config["file_cache_path"]}/log4j.properties" do
  source "app.log4j.properties.erb"
  owner node["hadoop_spark"]["user"]
  mode 0750
  action :create
  variables({
               :private_ip => private_ip
  })
end



hopsworks_user=node["hops"]["hdfs"]["user"]
hopsworks_group=node["hops"]["group"]

if node.attribute?('hopsworks') == true
  if node['hopsworks'].attribute?('user') == true
     hopsworks_user = node['hopsworks']['user']
  end
end
logs_dir="/user/#{node["hadoop_spark"]["user"]}"

hops_hdfs_directory "#{Chef::Config["file_cache_path"]}/log4j.properties" do
  action :put_as_superuser
  owner node["hadoop_spark"]["user"]
  group node["hops"]["group"]
  mode "1775"
  dest "#{logs_dir}/log4j.properties"
end



graphite_port=2003

if node.attribute?('influxdb') == true
  if node['influxdb'].attribute?('graphite') == true
    if node['influxdb']['graphite'].attribute?('port') == true
      graphite_port=node['influxdb']['graphite']['port']
    end
  end
end
  


# Add spark metrics.properties file to HDFS. Used by Grafana.

template "#{Chef::Config["file_cache_path"]}/metrics.properties" do
  source "metrics.properties.erb"
  owner hopsworks_user
  mode 0750
  action :create
  variables({
              :private_ip => private_ip,
              :graphite_port => graphite_port
  })
end

hops_hdfs_directory "#{Chef::Config["file_cache_path"]}/metrics.properties" do
  action :put_as_superuser
  owner node["hadoop_spark"]["user"]
  group node["hops"]["group"]
  mode "1775"
  dest "/user/#{node["hadoop_spark"]["user"]}/metrics.properties"
end	




hopsUtil=File.basename(node["hadoop_spark"]["hops_util"]["url"])
 
remote_file "#{Chef::Config["file_cache_path"]}/#{hopsUtil}" do
  source node["hadoop_spark"]["hops_util"]["url"]
  owner hopsworks_user
  group node["hops"]["group"]
  mode "1775"
  action :create
end

hops_hdfs_directory "#{Chef::Config["file_cache_path"]}/hops-util-0.1.jar" do
  action :put_as_superuser
  owner node["hadoop_spark"]["user"]
  group node["hops"]["group"]
  mode "1755"
  dest "/user/#{node["hadoop_spark"]["user"]}/hops-util-0.1.jar"
end

hopsKafkaJar=File.basename(node["hadoop_spark"]["hops_spark_kafka_example"]["url"])
 
remote_file "#{Chef::Config["file_cache_path"]}/#{hopsKafkaJar}" do
  source node["hadoop_spark"]["hops_spark_kafka_example"]["url"]
  owner hopsworks_user
  group node["hops"]["group"]
  mode "1775"
  action :create
end

hops_hdfs_directory "#{Chef::Config["file_cache_path"]}/#{hopsKafkaJar}" do
  action :put_as_superuser
  owner hopsworks_user
  group node["hops"]["group"]
  mode "1755"
  dest "/user/#{hopsworks_user}/#{hopsKafkaJar}"
end

