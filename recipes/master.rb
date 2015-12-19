
spark_start "master" do
  action :start_master
end

template"#{node[:spark][:home]}/conf/slaves" do
  source "slaves.erb"
  owner node[:spark][:user]
  group node[:spark][:group]
  mode 0655
end


homedir = node[:spark][:user].eql?("root") ? "/root" : "/home/#{node[:spark][:user]}"


# bash "generate-ssh-keypair-for-master" do
#  user node[:spark][:user]
#   code <<-EOF
#      ssh-keygen -b 2048 -f #{homedir}/.ssh/id_rsa -t rsa -q -N ''
#   EOF
#  not_if { ::File.exists?( "#{homedir}/.ssh/id_rsa" ) }
# end

# spark_master "#{homedir}" do
#   action :return_publickey
# end

kagent_keys "#{homedir}" do
  cookbook_user node[:spark][:user]
  cookbook_group node[:spark][:group]
  action :generate  
end  

kagent_keys "#{homedir}" do
  cookbook_user node[:spark][:user]
  cookbook_group node[:spark][:group]
  cookbook_name "spark"
  cookbook_recipe "master"  
  action :return_publickey
end  
