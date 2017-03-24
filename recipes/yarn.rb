# Creating symbolic links from spark jars in the lib/ directory where spark is installed to 
# the directory containing yarn jars in hadoop. Hopefully, yarn will pick up these jars and add them
# to the HADOOP_CLASSPATH :)
# One potential problem could be if you install.hadoop_spark.as a different user than the default user 'yarn'.
# Then the symbolic link may not be able to be created due to a lack of file privileges.
# 

home = node.hops.hdfs.user_home

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
