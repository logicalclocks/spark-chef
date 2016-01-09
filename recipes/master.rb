
spark_start "master" do
  action :start_master
end

hadoop_hdfs_directory "#{node[:hdfs][:user_home]}/#{node[:spark][:user]}/share/lib" do 
  action :create_as_superuser
  owner node[:spark][:user]
  group node[:spark][:group]
  mode "755"
end

hadoop_hdfs_directory "#{node[:spark][:home]}/lib/spark-assembly-#{node[:spark][:version]}-hadoop#{node[:hadoop][:version]}.jar" do
  action :put
  dest "#{node[:hdfs][:user_home]}/#{node[:spark][:user]}/share/lib/spark-assembly.jar"
  owner node[:spark][:user]
  group node[:spark][:group]
  mode "0755"
end

# hdfs dfs -mkdir -p /user/spark/share/lib 
# hdfs dfs -put $SPARK_HOME/lib/spark-assembly-*.jar  \     
# /user/spark/share/lib/spark-assembly.jar 
# SPARK_JAR=hdfs://<nn>:<port>/user/spark/share/lib/spark-assembly.jar

template"#{node[:spark][:home]}/conf/slaves" do
  source "slaves.erb"
  owner node[:spark][:user]
  group node[:spark][:group]
  mode 0655
end


homedir = node[:spark][:user].eql?("root") ? "/root" : "/home/#{node[:spark][:user]}"

kagent_keys "#{homedir}" do
  cb_user node[:spark][:user]
  cb_group node[:spark][:group]
  action :generate  
end  

kagent_keys "#{homedir}" do
  cb_user node[:spark][:user]
  cb_group node[:spark][:group]
  cb_name "spark"
  cb_recipe "master"  
  action :return_publickey
end  
