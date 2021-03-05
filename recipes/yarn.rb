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


hopsVerification = File.basename(node['hadoop_spark']['hops_verification']['url'])
hopsExamplesSpark=File.basename(node['hadoop_spark']['hopsexamples_spark']['url'])
hopsExamplesFeaturestoreTour=File.basename(node['hadoop_spark']['hopsexamples_featurestore_tour']['url'])
hsfs_utils = File.basename(node['hadoop_spark']['hsfs']['utils']['download_url'])

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
  remote_file "#{Chef::Config['file_cache_path']}/#{hopsVerification}" do
    source node['hadoop_spark']['hops_verification']['url']
    owner node['hadoop_spark']['user']
    group node['hops']['group']
    mode "0755"
    action :create
  end

  remote_file "#{Chef::Config['file_cache_path']}/#{hopsExamplesSpark}" do
    source node['hadoop_spark']['hopsexamples_spark']['url']
    owner node['hadoop_spark']['user']
    group node['hops']['group']
    mode "1755"
    action :create
  end

  remote_file "#{Chef::Config['file_cache_path']}/#{hopsExamplesFeaturestoreTour}" do
    source node['hadoop_spark']['hopsexamples_featurestore_tour']['url']
    owner node['hadoop_spark']['user']
    group node['hops']['group']
    mode "1755"
    action :create
  end

  remote_file "#{Chef::Config['file_cache_path']}/#{hsfs_utils}" do
    source node['hadoop_spark']['hsfs']['utils']['download_url']
    owner node['hadoop_spark']['user']
    group node['hops']['group']
    mode "1755"
    action :create
  end
end 

# Only the first of the spark::yarn hosts needs to run this code (not all of them)
#see HOPSWORKS-572 why the following if clause changed
#if private_ip.eql? node['hadoop_spark']['yarn']['private_ips'][0]
if is_first_spark_yarn_to_run

  hops_hdfs_directory "#{home}" do
    action :create_as_superuser
    owner node['hadoop_spark']['user']
    group node['hops']['group']
    mode "1777"
  end


  hops_hdfs_directory "#{home}/#{node['hadoop_spark']['user']}" do
    action :create_as_superuser
    owner node['hadoop_spark']['user']
    group node['hops']['group']
    mode "1777"
  end

  hops_hdfs_directory "#{home}/#{node['hadoop_spark']['user']}/eventlog" do
    action :create_as_superuser
    owner node['hadoop_spark']['user']
    group node['hops']['group']
    mode "1775"
  end

  hops_hdfs_directory "#{home}/#{node['hadoop_spark']['user']}/spark-warehouse" do
    action :create_as_superuser
    owner node['hadoop_spark']['user']
    group node['hops']['group']
    mode "1775"
  end

  hops_hdfs_directory "#{home}/#{node['hadoop_spark']['user']}/share/lib" do
    action :create_as_superuser
    owner node['hadoop_spark']['user']
    group node['hops']['group']
    mode "1775"
  end

  hopsworks_user=node['hops']['hdfs']['user']

  if node.attribute?('hopsworks') == true
    if node['hopsworks'].attribute?('user') == true
      hopsworks_user = node['hopsworks']['user']
    end
  end

  hops_hdfs_directory "#{Chef::Config['file_cache_path']}/#{hopsVerification}" do
    owner node['hadoop_spark']['user']
    group node['hops']['group']
    mode "1755"
    dest "/user/#{node['hadoop_spark']['user']}/#{hopsVerification}"
    action :replace_as_superuser
  end

  hops_hdfs_directory "#{Chef::Config['file_cache_path']}/#{hopsExamplesSpark}" do
    action :replace_as_superuser
    owner node['hadoop_spark']['user']
    group node['hops']['group']
    mode "1755"
    dest "/user/#{node['hadoop_spark']['user']}/#{hopsExamplesSpark}"
  end

  hops_hdfs_directory "#{Chef::Config['file_cache_path']}/#{hopsExamplesFeaturestoreTour}" do
    action :replace_as_superuser
    owner node['hadoop_spark']['user']
    group node['hops']['group']
    mode "1755"
    dest "/user/#{node['hadoop_spark']['user']}/#{hopsExamplesFeaturestoreTour}"
  end

  hops_hdfs_directory "#{node['hadoop_spark']['home']}/conf/log4j.properties" do
    action :replace_as_superuser
    owner node['hadoop_spark']['user']
    group node['hops']['group']
    mode "1755"
    dest "/user/#{node['hadoop_spark']['user']}/log4j.properties"
  end

  hops_hdfs_directory "#{Chef::Config['file_cache_path']}/#{hsfs_utils}" do
    action :replace_as_superuser
    owner node['hadoop_spark']['user']
    group node['hops']['group']
    mode "1755"
    dest "/user/#{node['hadoop_spark']['user']}/#{hsfs_utils}"
  end

  #copy hive-site.xml to hdfs so that node-managers can download it to containers for running hive-jobs/notebooks
  hops_hdfs_directory "#{node['hadoop_spark']['home']}/conf/hive-site.xml" do
    action :replace_as_superuser
    owner node['hadoop_spark']['user']
    group node['hops']['group']
    mode "1755"
    dest "/user/#{node['hadoop_spark']['user']}/hive-site.xml"
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
    rel_paths ["#{Chef::Config['file_cache_path']}/#{hopsExamplesSpark}", "#{Chef::Config['file_cache_path']}/#{hopsExamplesFeaturestoreTour}", "#{Chef::Config['file_cache_path']}/#{hsfs_utils}", "#{Chef::Config['file_cache_path']}/#{hopsVerification}"]
    rel_tours_info [
                    "/user/#{node['hadoop_spark']['user']}/#{hopsExamplesSpark}", 
                    "/user/#{node['hadoop_spark']['user']}/#{hopsExamplesFeaturestoreTour}",
                    "/user/#{node['hadoop_spark']['user']}/#{hopsExamplesFeaturestoreTour}", 
                    "/user/#{node['hadoop_spark']['user']}/#{hsfs_utils}", 
                    "/user/#{node['hadoop_spark']['user']}/#{hopsVerification}"
                  ]  
    abs_tours_info [
                ["#{node['hadoop_spark']['home']}/conf/log4j.properties", "/user/#{node['hadoop_spark']['user']}/log4j.properties"],
                ["#{node['hadoop_spark']['home']}/conf/hive-site.xml", "/user/#{node['hadoop_spark']['user']}/hive-site.xml"]
              ]
    owner node['hadoop_spark']['user']
    group node['hops']['group']
    mode "1755"
  end 
end