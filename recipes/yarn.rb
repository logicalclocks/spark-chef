# Creating symbolic links from.hadoop_spark.jars in the lib/ directory where.hadoop_spark.is installed to 
# the directory containing yarn jars in.apache_hadoop. Hopefully, yarn will pick up these jars and add them
# to the HADOOP_CLASSPATH :)
# One potential problem could be if you install.hadoop_spark.as a different user than the default user 'yarn'.
# Then the symbolic link may not be able to be created due to a lack of file privileges.
# 


home = node.apache_hadoop.hdfs.user_home

apache_hadoop_hdfs_directory "#{home}" do
  action :create_as_superuser
  owner node.hadoop_spark.user
  group node.apache_hadoop.group
  mode "1755"
end


apache_hadoop_hdfs_directory "#{home}/#{node.hadoop_spark.user}" do
  action :create_as_superuser
  owner node.hadoop_spark.user
  group node.apache_hadoop.group
  mode "1755"
end

apache_hadoop_hdfs_directory "#{node.hadoop_spark.home}/lib/spark-assembly-#{node.hadoop_spark.version}-hadoop#{node.apache_hadoop.version}.jar" do
  action :put_as_superuser
  owner node.hadoop_spark.user
  group node.apache_hadoop.group
  mode "1755"
  dest "#{home}/#{node.hadoop_spark.user}.hadoop_spark.jar"
end
