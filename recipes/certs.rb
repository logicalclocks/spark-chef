bash 'materialize_truststores_from_hdfs' do
  user "root"
  code <<-EOH
        su #{node['hops']['hdfs']['user']} -c '#{node['hops']['base_dir']}/bin/hdfs dfs -copyToLocal -f "/user/#{node['hadoop_spark']['user']}/cacerts.jks" /tmp'
        mv /tmp/cacerts.jks "#{node['hadoop_spark']['conf_dir']}/cacerts.jks"
        chmod 444 "#{node['hadoop_spark']['conf_dir']}/cacerts.jks"
        chown #{node['hadoop_spark']['user']}:#{node['hops']['group']} "#{node['hadoop_spark']['conf_dir']}/cacerts.jks"

        su #{node['hops']['hdfs']['user']} -c '#{node['hops']['base_dir']}/bin/hdfs dfs -copyToLocal -f "/user/#{node['hadoop_spark']['user']}/cacerts.pem" /tmp'
        mv /tmp/cacerts.pem "#{node['hadoop_spark']['conf_dir']}/cacerts.pem"
        chmod 444 "#{node['hadoop_spark']['conf_dir']}/cacerts.pem"
        chown #{node['hadoop_spark']['user']}:#{node['hops']['group']} "#{node['hadoop_spark']['conf_dir']}/cacerts.pem"
  EOH
end
