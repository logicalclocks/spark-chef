action :start_master do

  bash "start-master" do
    user node.hadoop_spark.user
    group node.hadoop_spark.group
    cwd node.hadoop_spark.base_dir
    code <<-EOF
     ./sbin/start-master.sh
     if [ $? -ne 0 ] ; then
         ./sbin/stop-master.sh
         ./sbin/start-master.sh
     fi
    EOF
  end
 
end


action :start_worker do

  bash "start-worker" do
    user node.hadoop_spark.user
    group node.hadoop_spark.group
    cwd node.hadoop_spark.base_dir
    code <<-EOF
     
    ./sbin/start-slave.sh #{new_resource.master_url}
     if [ $? -ne 0 ] ; then
         ./sbin/stop-slave.sh
         ./sbin/start-slave.sh #{new_resource.master_url}
     fi
    EOF
#    not_if "#{node.hadoop_spark.home}/sbin/start-slave.sh --properties-file #{node.hadoop_spark.home}/conf/spark-defaults.conf | grep \"stop it first\""
     not_if "jps | grep Worker"
  end
 
end
