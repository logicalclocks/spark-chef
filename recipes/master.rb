
hadoop_spark_start "master" do
  action :start_master
end

template"#{node['hadoop_spark']['home']}/conf/slaves" do
  source "slaves.erb"
  owner node['hadoop_spark']['user']
  group node['hadoop_spark']['group']
  mode 0655
end


homedir = node['hadoop_spark']['user'].eql?("root") ? "/root" : "/home/#{node['hadoop_spark']['user']}"

kagent_keys "#{homedir}" do
  cb_user node['hadoop_spark']['user']
  cb_group node['hadoop_spark']['group']
  action :generate  
end  

kagent_keys "#{homedir}" do
  cb_user node['hadoop_spark']['user']
  cb_group node['hadoop_spark']['group']
  cb_name "hadoop_spark"
  cb_recipe "master"  
  action :return_publickey
end  
