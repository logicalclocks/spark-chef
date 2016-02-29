
# Hack to prevent auto-start of services, see COOK-26
# ruby_block "package-#{pkg}" do
#   block do
#     begin
#       Chef::Resource::RubyBlock.send(:include, Hadoop::Helpers)
#       policy_rcd('disable') if node['platform_family'] == 'debian'
#       resources("package[#{pkg}]").run_action(:install)
#     ensure
#       policy_rcd('enable') if node['platform_family'] == 'debian'
#     end
#   end
#   only_if { node['hadoop']['distribution'] == 'cdh' }
# end


libpath = File.expand_path '../../../kagent/libraries', __FILE__
require File.join(libpath, 'inifile')

my_ip = my_private_ip()
my_public_ip = my_public_ip()

firstNN = "hdfs://" + private_recipe_ip("hadoop", "nn") + ":#{node[:hadoop][:nn][:port]}"

  #dfs =node['hadoop']['core_site']['fs.defaultFS']

eventlog_dir =
  if node['spark']['spark_defaults'].key?('spark.eventLog.dir')
    node['spark']['spark_defaults']['spark.eventLog.dir']
  else
    node[:hdfs][:user_home] + "/" + node[:spark][:user] + "/applicationHistory"
  end

tmp_dirs   = ["#{node[:hdfs][:user_home]}/#{node[:spark][:user]}", eventlog_dir ]
for d in tmp_dirs
  hadoop_hdfs_directory d do
    action :create
    owner node[:spark][:user]
    group node[:spark][:group]
    mode "1771"
    not_if ". #{node[:hadoop][:home]}/sbin/set-env.sh && #{node[:hadoop][:home]}/bin/hdfs dfs -test -d #{d}"
  end
end

# service 'spark-history-server' do
#   status_command "#{s_cmd} status"
#   start_command "#{s_cmd} start"
#   stop_command "#{s_cmd} stop"
#   restart_command "#{s_cmd} restart"
#   supports [:restart => true, :reload => false, :status => true]
#   action :nothing
# end
