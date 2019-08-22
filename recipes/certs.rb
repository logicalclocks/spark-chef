bash 'materialize_truststores_from_hdfs' do
  user "root"
  code <<-EOH
        su #{node['hops']['user']}
        #{node['hops']['base_dir']}/bin/hdfs dfs -copyToLocal -f "/user/#{node['hadoop_spark']['user']}/cacerts.jks" "#{node['hadoop_spark']['conf_dir']}/"
        chmod 444 "#{node['hadoop_spark']['conf_dir']}/cacerts.jks"
        #{node['hops']['base_dir']}/bin/hdfs dfs -copyToLocal -f "/user/#{node['hadoop_spark']['user']}/cacerts.pem" "#{node['hadoop_spark']['conf_dir']}/" 
        chmod 444 "#{node['hadoop_spark']['conf_dir']}/cacerts.pem"
  EOH
end
