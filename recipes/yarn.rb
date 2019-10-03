home = node['hops']['hdfs']['user_home']
private_ip=my_private_ip()


#
# local directory logs
#
directory node['hadoop_spark']['local']['dir'] do
  owner node['hadoop_spark']['user']
  group node['hops']['group']
  mode "770"
  action :create
  recursive true
  not_if { File.directory?("#{node['hadoop_spark']['local']['dir']}") }
end

# Package Spark jars
spark_packaged = "#{node['hadoop_spark']['home']}/.hadoop_spark.packaged_#{node['hadoop_spark']['version']}"

bash 'extract_hadoop_spark' do
  user "root"
  code <<-EOH
                set -e
                cd #{node['hadoop_spark']['home']}/jars
                zip -o #{node['hadoop_spark']['yarn']['archive']} *
		cd ..
                mv jars/#{node['hadoop_spark']['yarn']['archive']} .
                mkdir -p #{node['hadoop_spark']['home']}/logs
                touch #{spark_packaged}
                cd ..
                chown -R #{node['hadoop_spark']['user']}:#{node['hadoop_spark']['group']} #{node['hadoop_spark']['home']}
                chmod 750 #{node['hadoop_spark']['home']}
                # make the logs dir writeable by the sparkhistoryserver (runs as user 'hdfs')
                chmod 770 #{node['hadoop_spark']['home']}/logs
        EOH
  not_if { ::File.exists?( spark_packaged ) }
end



begin
  influxdb_ip = private_recipe_ip("hopsmonitor","default")
rescue
  Chef::Log.error "could not find the influxdb ip!"
end

template "#{node['hadoop_spark']['base_dir']}/conf/metrics.properties" do
  source "metrics.properties.erb"
  owner node['hadoop_spark']['user']
  group node['hadoop_spark']['group']
  mode 0750
  action :create
  variables({
              :influxdb_ip => influxdb_ip
            })
end

template"#{node['hadoop_spark']['conf_dir']}/log4j.properties" do
  source "app.log4j.properties.erb"
  owner node['hadoop_spark']['user']
  group node['hadoop_spark']['group']
  mode 0650
end

hopsUtil=File.basename(node['hadoop_spark']['hopsutil']['url'])
remote_file "#{node['hadoop_spark']['home']}/jars/#{hopsUtil}" do
  source node['hadoop_spark']['hopsutil']['url']
  owner node['hadoop_spark']['user']
  group node['hops']['group']
  mode "1755"
  action :create
end

# Only the first of the spark::yarn hosts needs to run this code (not all of them)
#see HOPSWORKS-572 why the following if clause changed
#if private_ip.eql? node['hadoop_spark']['yarn']['private_ips'][0]
if (File.exist?("#{node['kagent']['certs_dir']}/cacerts.jks"))

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

  bash "set_userspark_storage_type" do
    user node['hops']['hdfs']['user']  
    group node['hops']['group'] 
    code <<-EOH
      #{node['hops']['bin_dir']}/hdfs storagepolicies -setStoragePolicy -path #{home}/#{node['hadoop_spark']['user']} -policy DB
    EOH
    action :run
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

  hops_hdfs_directory "#{node['hadoop_spark']['home']}/#{node['hadoop_spark']['yarn']['archive']}" do
    action :replace_as_superuser
    owner node['hadoop_spark']['user']
    group node['hops']['group']
    mode "1775"
    dest "#{node['hadoop_spark']['yarn']['archive_hdfs']}"
  end

  hopsworks_user=node['hops']['hdfs']['user']
  hopsworks_group=node['hops']['group']

  if node.attribute?('hopsworks') == true
    if node['hopsworks'].attribute?('user') == true
      hopsworks_user = node['hopsworks']['user']
    end
  end

  hopsVerification = File.basename(node['hadoop_spark']['hops_verification']['url'])
  remote_file "#{Chef::Config['file_cache_path']}/#{hopsVerification}" do
    source node['hadoop_spark']['hops_verification']['url']
    owner node['hadoop_spark']['user']
    group node['hops']['group']
    mode "0755"
    action :create
  end

  hops_hdfs_directory "#{Chef::Config['file_cache_path']}/#{hopsVerification}" do
    owner node['hadoop_spark']['user']
    group node['hops']['group']
    mode "1755"
    dest "/user/#{node['hadoop_spark']['user']}/#{hopsVerification}"
    action :replace_as_superuser
  end
  
  hopsExamplesSpark=File.basename(node['hadoop_spark']['hopsexamples_spark']['url'])
  remote_file "#{Chef::Config['file_cache_path']}/#{hopsExamplesSpark}" do
    source node['hadoop_spark']['hopsexamples_spark']['url']
    owner node['hadoop_spark']['user']
    group node['hops']['group']
    mode "1755"
    action :create
  end

  hops_hdfs_directory "#{Chef::Config['file_cache_path']}/#{hopsExamplesSpark}" do
    action :replace_as_superuser
    owner node['hadoop_spark']['user']
    group node['hops']['group']
    mode "1755"
    dest "/user/#{node['hadoop_spark']['user']}/#{hopsExamplesSpark}"
  end

  hopsExamplesFeaturestoreTour=File.basename(node['hadoop_spark']['hopsexamples_featurestore_tour']['url'])
  remote_file "#{Chef::Config['file_cache_path']}/#{hopsExamplesFeaturestoreTour}" do
    source node['hadoop_spark']['hopsexamples_featurestore_tour']['url']
    owner node['hadoop_spark']['user']
    group node['hops']['group']
    mode "1755"
    action :create
  end

  hops_hdfs_directory "#{Chef::Config['file_cache_path']}/#{hopsExamplesFeaturestoreTour}" do
    action :replace_as_superuser
    owner node['hadoop_spark']['user']
    group node['hops']['group']
    mode "1755"
    dest "/user/#{node['hadoop_spark']['user']}/#{hopsExamplesFeaturestoreTour}"
  end

  hopsExamplesFeaturestoreUtil4j=File.basename(node['hadoop_spark']['hopsexamples_featurestore_util4j']['url'])
  remote_file "#{Chef::Config['file_cache_path']}/#{hopsExamplesFeaturestoreUtil4j}" do
    source node['hadoop_spark']['hopsexamples_featurestore_util4j']['url']
    owner node['hadoop_spark']['user']
    group node['hops']['group']
    mode "1755"
    action :create
  end

  hops_hdfs_directory "#{Chef::Config['file_cache_path']}/#{hopsExamplesFeaturestoreUtil4j}" do
    action :replace_as_superuser
    owner node['hadoop_spark']['user']
    group node['hops']['group']
    mode "1755"
    dest "/user/#{node['hadoop_spark']['user']}/#{hopsExamplesFeaturestoreUtil4j}"
  end

  hopsExamplesFeaturestoreUtilPy=File.basename(node['hadoop_spark']['hopsexamples_featurestore_util_py']['url'])
  remote_file "#{Chef::Config['file_cache_path']}/#{hopsExamplesFeaturestoreUtilPy}" do
    source node['hadoop_spark']['hopsexamples_featurestore_util_py']['url']
    owner node['hadoop_spark']['user']
    group node['hops']['group']
    mode "1755"
    action :create
  end

  hops_hdfs_directory "#{Chef::Config['file_cache_path']}/#{hopsExamplesFeaturestoreUtilPy}" do
    action :replace_as_superuser
    owner node['hadoop_spark']['user']
    group node['hops']['group']
    mode "1755"
    dest "/user/#{node['hadoop_spark']['user']}/#{hopsExamplesFeaturestoreUtilPy}"
  end

  hops_hdfs_directory "#{node['hadoop_spark']['base_dir']}/conf/metrics.properties"  do
    action :replace_as_superuser
    owner node['hadoop_spark']['user']
    group node['hadoop_spark']['group']
    mode "1755"
    dest "/user/#{node['hadoop_spark']['user']}/metrics.properties"
  end


  hops_hdfs_directory "#{node['hadoop_spark']['home']}/conf/metrics.properties" do
    action :replace_as_superuser
    owner node['hadoop_spark']['user']
    group node['hops']['group']
    mode "1755"
    dest "/user/#{node['hops']['hdfs']['user']}/metrics.properties"
  end

  hops_hdfs_directory "#{node['hadoop_spark']['home']}/conf/log4j.properties" do
    action :replace_as_superuser
    owner node['hadoop_spark']['user']
    group node['hops']['group']
    mode "1755"
    dest "/user/#{node['hadoop_spark']['user']}/log4j.properties"
  end

  encyption_password = "adminpw"
  if node.attribute?('hopsworks') && node['hopsworks'].attribute?('master') && node['hopsworks']['master'].attribute?('password')
    encyption_password = node['hopsworks']['master']['password']
  end

  cacerts_pem_filename = "cacerts.pem"
  bash 'materialize_truststore and convert to pem' do
    user "root"
    code <<-EOH
        cp -f #{node['kagent']['certs_dir']}/cacerts.jks /tmp
        chmod 755 /tmp/cacerts.jks
        keytool -importkeystore -srckeystore /tmp/cacerts.jks -destkeystore /tmp/cacerts.p12 -srcstoretype jks -deststoretype pkcs12 -noprompt -srcstorepass #{encyption_password} -deststorepass #{encyption_password} 
        openssl pkcs12 -in /tmp/cacerts.p12 -nokeys -out /tmp/#{cacerts_pem_filename} -passin pass:#{encyption_password}
        chmod 444 /tmp/#{cacerts_pem_filename}
    EOH
  end

  #Copy glassfish truststore to hdfs under hdfs user so that HopsUtil can make https requests to HopsWorks
  hops_hdfs_directory "/tmp/cacerts.jks" do
    action :put_as_superuser
    owner node['hadoop_spark']['user']
    group node['hops']['group']
    mode "0444"
    dest "/user/#{node['hadoop_spark']['user']}/cacerts.jks"
  end

  #Copy glassfish truststore (PEM) to hdfs under hdfs user so that hops-util-py can make https requests to Hopsworks
  hops_hdfs_directory "/tmp/cacerts.pem" do
    action :put_as_superuser
    owner node['hadoop_spark']['user']
    group node['hops']['group']
    mode "0444"
    dest "/user/#{node['hadoop_spark']['user']}/cacerts.pem"
  end

  bash 'cleanup_truststores' do
    user "root"
    code <<-EOH
        rm -f /tmp/cacerts.jks
        rm -f /tmp/#{cacerts_pem_filename}
        rm -f /tmp/cacerts.p12
	      rm -f #{node['kagent']['certs_dir']}/cacerts.jks
    EOH
  end

  #copy hive-site.xml to hdfs so that node-managers can download it to containers for running hive-jobs/notebooks
  hops_hdfs_directory "#{node['hadoop_spark']['home']}/conf/hive-site.xml" do
    action :replace_as_superuser
    owner node['hadoop_spark']['user']
    group node['hops']['group']
    mode "1755"
    dest "/user/#{node['hadoop_spark']['user']}/hive-site.xml"
  end

  if node['install']['enterprise']['install'].casecmp? "true"
    source = "#{node['install']['enterprise']['download_url']}/featurestore-helpers/#{node['install']['version']}/ft_import.py"
    remote_file "#{Chef::Config['file_cache_path']}/ft_import.py" do
      user node['hadoop_spark']['user']
      node['hadoop_spark']['group']
      source source
      headers get_ee_basic_auth_header()
      sensitive true
      mode 0555
      action :create_if_missing
    end

    hops_hdfs_directory "#{Chef::Config['file_cache_path']}/ft_import.py" do
      action :replace_as_superuser
      owner node['hadoop_spark']['user']
      group node['hops']['group']
      mode "1775"
      dest "/user/#{node['hadoop_spark']['user']}/ft_import.py"
    end

    source = "#{node['install']['enterprise']['download_url']}/featurestore-helpers/#{node['install']['version']}/ft_trainingdataset_job.py"
    remote_file "#{Chef::Config['file_cache_path']}/ft_trainingdataset_job.py" do
      user node['hadoop_spark']['user']
      node['hadoop_spark']['group']
      source source
      headers get_ee_basic_auth_header()
      sensitive true
      mode 0555
      action :create_if_missing
    end

    hops_hdfs_directory "#{Chef::Config['file_cache_path']}/ft_trainingdataset_job.py" do
      action :replace_as_superuser
      owner node['hadoop_spark']['user']
      group node['hops']['group']
      mode "1775"
      dest "/user/#{node['hadoop_spark']['user']}/ft_trainingdataset_job.py"
    end

    bash 'cleanup_truststores' do
    user "root"
    code <<-EOH
          rm -f /tmp/cacerts.jks
	        rm -f #{node['kagent']['certs_dir']}/cacerts.jks
          rm -f /tmp/cacerts.pem
        EOH
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

when "rhel"

  # TODO - add 'netlib-java'
end


jarFile="spark-#{node['hadoop_spark']['version']}-yarn-shuffle.jar"


link "#{node['hops']['base_dir']}/share/hadoop/yarn/lib/#{jarFile}" do
  owner node['hops']['yarn']['user']
  group node['hops']['group']
  to "#{node['hadoop_spark']['base_dir']}/yarn/#{jarFile}"
end


# Support for 'R'
case node['platform_family']
when "debian"
 package "r-base" do
  action :install
 end

when "rhel"
  package "R" do
    action :install
  end
  package "R-devel" do
    action :install
  end
  package "libcurl-devel" do
    action :install
  end
  package "openssl-devel" do
    action :install
  end
end


