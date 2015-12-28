action :start_master do

  bash "start-master" do
    user node[:spark][:user]
    group node[:spark][:group]
    cwd node[:spark][:base_dir]
    code <<-EOF
     . sbin/spark-config.sh
     ./sbin/start-master.sh
     # ./sbin/spark-daemon.sh start org.apache.spark.deploy.master.Master 
    EOF
  end
 
end


action :start_worker do

  bash "start-worker" do
    user node[:spark][:user]
    group node[:spark][:group]
    cwd node[:spark][:base_dir]
    code <<-EOF
     
    . sbin/spark-config.sh

# Spark 1.4.x
    ./sbin/start-slave.sh #{new_resource.master_url}
# Spark 1.3.x
#    ./sbin/start-slave.sh #{new_resource.worker_id} #{new_resource.master_url}
    EOF
#    not_if "#{node[:spark][:home]}/sbin/start-slave.sh --properties-file #{node[:spark][:home]}/conf/spark-defaults.conf | grep \"stop it first\""
     not_if "jps | grep Worker"
  end
 
end
