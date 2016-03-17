
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
#   only_if { node.apache_hadoop.distribution == 'cdh' }
# end


my_ip = my_private_ip()
my_public_ip = my_public_ip()

firstNN = "hdfs://" + private_recipe_ip("apache_hadoop., "nn") + ":#{node.apache_hadoop.nn.port}"

eventlog_dir =
  if node.hadoop_spark.spark_defaults.key?(.hadoop_spark.eventLog.dir')
    "#{node.hadoop_spark.spark_defaults.hadoop_spark.eventLog.dir}"
  else
    "#{node.apache_hadoop.hdfs.user_home}/#{node.hadoop_spark.user}/applicationHistory"
  end

tmp_dirs   = ["#{node.apache_hadoop.hdfs.user_home}/#{node.hadoop_spark.user}", eventlog_dir ]
for d in tmp_dirs
 apache_hadoop.hdfs_directory d do
    action :create
    owner node.hadoop_spark.user
    group node.hadoop_spark.group
    mode "1771"
    not_if ". #{node.apache_hadoop.home}/sbin/set-env.sh && #{node.apache_hadoop.home}/bin/hdfs dfs -test -d #{d}"
  end
end
