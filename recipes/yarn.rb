
# 
# Creating symbolic links from spark jars in the lib/ directory where spark is installed to 
# the directory containing yarn jars in hadoop. Hopefully, yarn will pick up these jars and add them
# to the HADOOP_CLASSPATH :)
# One potential problem could be if you install spark as a different user than the default user 'yarn'.
# Then the symbolic link may not be able to be created due to a lack of file privileges.
# 
jars = ["datanucleus-api-jdo-3.2.6.jar",  "datanucleus-core-3.2.10.jar",  "datanucleus-rdbms-3.2.9.jar",  "spark-#{node[:spark][:version]}-yarn-shuffle.jar",  "spark-assembly-#{node[:spark][:version]}-hadoop#{node[:hadoop][:version]}.jar"]


# for jar in jars
#   jar.gsub! "-#{node[:spark][:version]}" ""
#   jar.gsub! "-#{node[:hadoop][:version]}" ""

#   file "#{node[:hadoop][:home]}/share/hadoop/yarn/#{jar}" do
#     owner node[:hadoop][:yarn][:user]
#     group node[:hadoop][:group]
#     action :delete
#   end

#   link "#{node[:hadoop][:home]}/share/hadoop/yarn/#{jar}" do
#     owner node[:hadoop][:yarn][:user]
#     group node[:hadoop][:group]
#     to "#{node[:spark][:home]}/lib/#{jar}"
#   end
# end


hadoop_hdfs_directory "/user/#{node[:spark][:user]}" do
#  action :create_as_superuser
  action :create
  owner node[:spark][:user]
  group node[:hadoop][:group]
  mode "1755"
end

hadoop_hdfs_directory "#{node[:spark][:home]}/lib/spark-assembly-#{node[:spark][:version]}-hadoop#{node[:hadoop][:version]}.jar" do
  action :put_as_superuser
  owner node[:spark][:user]
  group node[:hadoop][:group]
  mode "1755"
  dest "/user/#{node[:spark][:user]}/spark.jar"
end

#
# HopsWorks looks for this if it can't find a version in hdfs.
#
link "#{node[:spark][:home]}/spark.jar" do
  owner node[:spark][:user]
  group node[:hadoop][:group]
  to "#{node[:spark][:home]}/lib/spark-assembly-#{node[:spark][:version]}-hadoop#{node[:hadoop][:version]}.jar"
end
