
spark_start "master" do
  action :start_master
end

hadoop_hdfs_directory "/user/#{node[:spark][:user]}/share/lib" do 
  action :create_as_superuser
  owner node[:spark][:user]
  group node[:spark][:group]
  mode "755"
end

hadoop_hdfs_directory "#{node[:spark][:home]}/assembly/lib/spark-assembly_#{node[:spark][:version}-hadoop2.4.0.jar" do
  action :put
  dest "/user/#{node[:spark][:user]}/share/lib/spark-assembly.jar"
  owner node[:spark][:user]
  mode "0755"
end

# hdfs dfs -mkdir -p /user/spark/share/lib 
# hdfs dfs -put $SPARK_HOME/assembly/lib/spark-assembly_*.jar  \     
# /user/spark/share/lib/spark-assembly.jar 
# SPARK_JAR=hdfs://<nn>:<port>/user/spark/share/lib/spark-assembly.jar

template"#{node[:spark][:home]}/conf/slaves" do
  source "slaves.erb"
  owner node[:spark][:user]
  group node[:spark][:group]
  mode 0655
end

link "#{node[:spark][:home]}/spark.jar" do
  owner node[:spark][:user]
  group node[:spark][:group]
  to "#{node[:spark][:home]}/assembly/lib/spark-assembly_#{node[:spark][:version}-hadoop2.4.0.jar"
end

homedir = node[:spark][:user].eql?("root") ? "/root" : "/home/#{node[:spark][:user]}"


bash "generate-ssh-keypair-for-master" do
 user node[:spark][:user]
  code <<-EOF
     ssh-keygen -b 2048 -f #{homedir}/.ssh/id_rsa -t rsa -q -N ''
  EOF
 not_if { ::File.exists?( "#{homedir}/.ssh/id_rsa" ) }
end

template "#{homedir}/.ssh/config" do
  source "ssh_config.erb"
  owner node[:spark][:user]
  group node[:spark][:group]
  mode 0600
end



spark_master "#{homedir}" do
  action :return_publickey
end
