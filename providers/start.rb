action :start_master do

  bash "start-master" do
    user node[:spark][:user]
    group node[:spark][:group]
    cwd node[:spark][:base_dir]
    code <<-EOF
     . sbin/spark-config.sh
     ./sbin/start-master.sh
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
# Spark >1.4.x
    ./sbin/start-slave.sh #{new_resource.master_url}
    EOF
     not_if "jps | grep Worker"
  end
 
end
