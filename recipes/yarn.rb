home = node['hops']['hdfs']['user_home']
private_ip=my_private_ip()

# Create logs dir.
directory "#{node['hadoop_spark']['home']}/logs" do
  owner node['hadoop_spark']['user']
  group node['hops']['group']
  mode "770"
  action :create
end

template "#{node['hadoop_spark']['base_dir']}/conf/metrics.properties" do
  source "metrics.properties.erb"
  owner node['hadoop_spark']['user']
  group node['hops']['group']
  mode 0750
  action :create
  variables({
    :pushgateway => consul_helper.get_service_fqdn("pushgateway.prometheus")
  })
end

nn_endpoint = consul_helper.get_service_fqdn("rpc.namenode") + ":#{node['hops']['nn']['port']}"
metastore_endpoint = consul_helper.get_service_fqdn("metastore.hive") + ":#{node['hive2']['metastore']['port']}"
template "#{node['hadoop_spark']['home']}/conf/hive-site.xml" do
  source "hive-site.xml.erb"
  owner node['hadoop_spark']['user']
  group node['hadoop_spark']['group']
  mode 0655
  variables({
                :nn_endpoint => nn_endpoint,
                :metastore_endpoint => metastore_endpoint
            })
end

eventlog_dir = "#{node['hops']['hdfs']['user_home']}/#{node['hadoop_spark']['user']}/applicationHistory"
historyserver_endpoint = consul_helper.get_service_fqdn("historyserver.spark") + ":#{node['hadoop_spark']['historyserver']['port']}"

template"#{node['hadoop_spark']['home']}/conf/spark-defaults.conf" do
  source "spark-defaults.conf.erb"
  owner node['hadoop_spark']['user']
  group node['hops']['group']
  mode 0655
  variables({
                :nn_endpoint => nn_endpoint,
                :eventlog_dir => eventlog_dir,
                :historyserver_endpoint => historyserver_endpoint
           })
end


hopsExamplesSpark=File.basename(node['hadoop_spark']['hopsexamples_spark']['url'])
hsfs_utils_py = File.basename(node['hadoop_spark']['hsfs']['utils']['py_download_url'])
hsfs_utils_java = File.basename(node['hadoop_spark']['hsfs']['utils']['java_download_url'])

is_head_node = false
if exists_local("hopsworks", "default") and exists_local("cloud", "default")
  unmanaged = false
  if node.attribute? 'cloud' and node['cloud'].attribute? 'init' and node['cloud']['init'].attribute? 'config' and node['cloud']['init']['config'].attribute? 'unmanaged'
    unmanaged = node['cloud']['init']['config']['unmanaged'].casecmp? 'true'
  end
  is_head_node = !unmanaged
end

is_first_spark_yarn_to_run = private_ip.eql?(node['hadoop_spark']['yarn']['private_ips'].sort[0])

if is_head_node || is_first_spark_yarn_to_run

  remote_file "#{Chef::Config['file_cache_path']}/#{hopsExamplesSpark}" do
    source node['hadoop_spark']['hopsexamples_spark']['url']
    owner node['hadoop_spark']['user']
    group node['hops']['group']
    mode "1755"
    action :create
  end

  remote_file "#{Chef::Config['file_cache_path']}/#{hsfs_utils_py}" do
    source node['hadoop_spark']['hsfs']['utils']['py_download_url']
    owner node['hadoop_spark']['user']
    group node['hops']['group']
    mode "1755"
    action :create
  end

  remote_file "#{Chef::Config['file_cache_path']}/#{hsfs_utils_java}" do
    source node['hadoop_spark']['hsfs']['utils']['java_download_url']
    owner node['hadoop_spark']['user']
    group node['hops']['group']
    mode "1755"
    action :create
  end

  ['open_high_low.py', 'avgs.py'].each do |tour_file|
    cookbook_file "#{Chef::Config['file_cache_path']}/#{tour_file}" do
      source "fs_tour/open_high_low.py"
      owner node['glassfish']['user']
      mode 0750
      action :create
    end
  end
end 

# Only the first of the spark::yarn hosts needs to run this code (not all of them)
#see HOPSWORKS-572 why the following if clause changed
#if private_ip.eql? node['hadoop_spark']['yarn']['private_ips'][0]
if is_first_spark_yarn_to_run

  ["#{home}",
   "#{home}/#{node['hadoop_spark']['user']}"].each do |hopsfs_dir|
    hops_hdfs_directory hopsfs_dir do
      action :create_as_superuser
      owner node['hadoop_spark']['user']
      group node['hops']['group']
      mode "1777"
    end
  end

  ["#{home}/#{node['hadoop_spark']['user']}/eventlog",
   "#{home}/#{node['hadoop_spark']['user']}/spark-warehouse",
   "#{home}/#{node['hadoop_spark']['user']}/share/lib"].each do |hopsfs_dir|
      hops_hdfs_directory hopsfs_dir do
        action :create_as_superuser
        owner node['hadoop_spark']['user']
        group node['hops']['group']
        mode "1775"
      end
  end

  {
    "#{Chef::Config['file_cache_path']}/#{hopsExamplesSpark}" => "/user/#{node['hadoop_spark']['user']}/#{hopsExamplesSpark}",
    "#{node['hadoop_spark']['home']}/conf/log4j.properties" => "/user/#{node['hadoop_spark']['user']}/log4j.properties",
    "#{Chef::Config['file_cache_path']}/#{hsfs_utils_py}" => "/user/#{node['hadoop_spark']['user']}/#{hsfs_utils_py}",
    "#{Chef::Config['file_cache_path']}/#{hsfs_utils_java}" => "/user/#{node['hadoop_spark']['user']}/#{hsfs_utils_java}",
    "#{Chef::Config['file_cache_path']}/open_high_low.py" => "/user/#{node['hadoop_spark']['user']}/open_high_low.py",
    "#{Chef::Config['file_cache_path']}/avgs.py" => "/user/#{node['hadoop_spark']['user']}/avgs.py"
  }.each do |src, dest|
    hops_hdfs_directory src do
      action :replace_as_superuser
      owner node['hadoop_spark']['user']
      group node['hops']['group']
      mode "1755"
      dest dest 
    end
  end
end

#
# Support Intel MKL library for matrix computations
# https://blog.cloudera.com/blog/2017/02/accelerating-apache-spark-mllib-with-intel-math-kernel-library-intel-mkl/
#
case node['platform_family']
when "debian"
  package "libnetlib-java" do
    action :install
  end
end


jarFile="spark-#{node['hadoop_spark']['version']}-yarn-shuffle.jar"
link "#{node['hops']['base_dir']}/share/hadoop/yarn/lib/#{jarFile}" do
  owner node['hops']['yarn']['user']
  group node['hops']['group']
  to "#{node['hadoop_spark']['base_dir']}/yarn/#{jarFile}"
end

if is_head_node
  hops_tours "Cache tour files locally" do 
    action :update_local_cache
    paths [
            "#{Chef::Config['file_cache_path']}/#{hopsExamplesSpark}", 
            "#{Chef::Config['file_cache_path']}/#{hsfs_utils_py}",
            "#{Chef::Config['file_cache_path']}/#{hsfs_utils_java}",
            "#{Chef::Config['file_cache_path']}/open_high_low.py",
            "#{Chef::Config['file_cache_path']}/avgs.py",
            "#{node['hadoop_spark']['home']}/conf/log4j.properties",
            "#{node['hadoop_spark']['home']}/conf/hive-site.xml"
          ]
    hdfs_paths [
                  "/user/#{node['hadoop_spark']['user']}/#{hopsExamplesSpark}", 
                  "/user/#{node['hadoop_spark']['user']}/#{hsfs_utils_py}",
                  "/user/#{node['hadoop_spark']['user']}/#{hsfs_utils_java}",
                  "/user/#{node['hadoop_spark']['user']}/log4j.properties",
                  "/user/#{node['hadoop_spark']['user']}/hive-site.xml",
                  "/user/#{node['hadoop_spark']['user']}/open_high_low.py",
                  "/user/#{node['hadoop_spark']['user']}/avgs.py"
                ]  
    owner node['hadoop_spark']['user']
    group node['hops']['group']
    mode "1755"
  end 
end
