include_recipe "hadoop_spark::config"

is_head_node = false
if exists_local("hopsworks", "default") and exists_local("cloud", "default")
  unmanaged = false
  if node.attribute? 'cloud' and node['cloud'].attribute? 'init' and node['cloud']['init'].attribute? 'config' and node['cloud']['init']['config'].attribute? 'unmanaged'
    unmanaged = node['cloud']['init']['config']['unmanaged'].casecmp? 'true'
  end
  is_head_node = !unmanaged
end

private_ip = my_private_ip()
is_first_spark_yarn_to_run = private_ip.eql?(node['hadoop_spark']['yarn']['private_ips'].sort[0])

hsfs_utils_py = File.basename(node['hadoop_spark']['hsfs']['utils']['py_download_url'])
hsfs_utils_java = File.basename(node['hadoop_spark']['hsfs']['utils']['java_download_url'])
hopsworks_jobs_py = File.basename(node['hadoop_spark']['hopsworks_jobs_py']['url'])

if (is_head_node || is_first_spark_yarn_to_run) && node["install"]["secondary_region"].casecmp?("false")

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

  remote_file "#{Chef::Config['file_cache_path']}/#{hopsworks_jobs_py}" do
    source node['hadoop_spark']['hopsworks_jobs_py']['url']
    owner node['hadoop_spark']['user']
    group node['hops']['group']
    mode "1755"
    action :create
  end
end 

# Only the first of the spark::yarn hosts needs to run this code (not all of them)
#see HOPSWORKS-572 why the following if clause changed
#if private_ip.eql? node['hadoop_spark']['yarn']['private_ips'][0]
if is_first_spark_yarn_to_run && node["install"]["secondary_region"].casecmp?("false")
  home = node['hops']['hdfs']['user_home']
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

  hops_hdfs_directory "#{node['hadoop_spark']['home']}/conf/log4j2.properties" do
    action :replace_as_superuser
    owner node['hadoop_spark']['user']
    group node['hops']['group']
    mode "1755"
    dest "/user/#{node['hadoop_spark']['user']}/log4j2.properties"
  end

  hops_hdfs_directory "#{Chef::Config['file_cache_path']}/#{hsfs_utils_py}" do
    action :replace_as_superuser
    owner node['hadoop_spark']['user']
    group node['hops']['group']
    mode "1755"
    dest "/user/#{node['hadoop_spark']['user']}/hsfs_utils.py"
  end

  hops_hdfs_directory "#{Chef::Config['file_cache_path']}/#{hsfs_utils_java}" do
    action :replace_as_superuser
    owner node['hadoop_spark']['user']
    group node['hops']['group']
    mode "1755"
    dest "/user/#{node['hadoop_spark']['user']}/hsfs-utils.jar"
  end

  hops_hdfs_directory "#{Chef::Config['file_cache_path']}/#{hopsworks_jobs_py}" do
    action :replace_as_superuser
    owner node['hadoop_spark']['user']
    group node['hops']['group']
    mode "1755"
    dest "/user/#{node['hadoop_spark']['user']}/#{hopsworks_jobs_py}"
  end
end

#
# Support Intel MKL library for matrix computations
# https://blog.cloudera.com/blog/2017/02/accelerating-apache-spark-mllib-with-intel-math-kernel-library-intel-mkl/
#
case node['platform_family']
when "debian"
  package "libnetlib-java" do
    retries 10
    retry_delay 30
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
            "#{Chef::Config['file_cache_path']}/#{hsfs_utils_py}",
            "#{Chef::Config['file_cache_path']}/#{hsfs_utils_java}",
            "#{Chef::Config['file_cache_path']}/#{hopsworks_jobs_py}",
            "#{node['hadoop_spark']['home']}/conf/log4j2.properties",
            "#{node['hadoop_spark']['home']}/conf/hive-site.xml"
          ]
    hdfs_paths [
                  "/user/#{node['hadoop_spark']['user']}/hsfs_utils.py",
                  "/user/#{node['hadoop_spark']['user']}/hsfs-utils.jar",
                  "/user/#{node['hadoop_spark']['user']}/#{hopsworks_jobs_py}",
                  "/user/#{node['hadoop_spark']['user']}/log4j2.properties",
                  "/user/#{node['hadoop_spark']['user']}/hive-site.xml"
                ]  
    owner node['hadoop_spark']['user']
    group node['hops']['group']
    mode "1755"
  end 
end
