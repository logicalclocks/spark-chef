
spark_start "master" do
  action :start_master
end

template"#{node.spark.home}/conf/slaves" do
  source "slaves.erb"
  owner node.spark.user
  group node.spark.group
  mode 0655
end


homedir = node.spark.user.eql?("root") ? "/root" : "/home/#{node.spark.user}"

kagent_keys "#{homedir}" do
  cb_user node.spark.user
  cb_group node.spark.group
  action :generate  
end  

kagent_keys "#{homedir}" do
  cb_user node.spark.user
  cb_group node.spark.group
  cb_name "spark"
  cb_recipe "master"  
  action :return_publickey
end  
