# Creating symbolic links from spark jars in the lib/ directory where spark is installed to 
# the directory containing yarn jars in hadoop. Hopefully, yarn will pick up these jars and add them
# to the HADOOP_CLASSPATH :)
# One potential problem could be if you install spark as a different user than the default user 'yarn'.
# Then the symbolic link may not be able to be created due to a lack of file privileges.
# 
#jars = ["datanucleus-api-jdo-3.2.6.jar",  "datanucleus-core-3.2.10.jar",  "datanucleus-rdbms-3.2.9.jar",  "spark-#{node.spark.version}-yarn-shuffle.jar",  "spark-assembly-#{node.spark.version}-hadoop#{node.hadoop.version}.jar"]


home = node.apache_hadoop.hdfs.user_home

hadoop_hdfs_directory "#{home}" do
  action :create_as_superuser
  owner node.spark.user
  group node.hadoop.group
  mode "1755"
end


hadoop_hdfs_directory "#{home}/#{node.spark.user}" do
  action :create_as_superuser
  owner node.spark.user
  group node.hadoop.group
  mode "1755"
end

hadoop_hdfs_directory "#{node.spark.home}/lib/spark-assembly-#{node.spark.version}-hadoop#{node.hadoop.version}.jar" do
  action :put_as_superuser
  owner node.spark.user
  group node.hadoop.group
  mode "1755"
  dest "#{home}/#{node.spark.user}/spark.jar"
end
