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