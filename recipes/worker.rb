
master_ip = private_recipe_ip("hadoop_spark","master")

# Generate a unique id for each worker using the list of ip addresses
# for the workers.
# Get the ip address of this worker. Then find the offset of this worker in the
# list of private_ips set by karamel. The offset of 'my_ip' is the worker_id.
my_ip = my_private_ip()
found_id = -1
id = 1
for worker in node['hadoop_spark']['worker']['private_ips']
  if my_ip.eql? worker
    Chef::Log.info "Found matching IP address in the list of nodes: #{worker} . ID= #{id}"
    found_id = id
  end
  id += 1
end 

if found_id == -1
   Chef::Log.fatal "Could not find matching IP address in list the.hadoop_spark.workers."
end


hadoop_spark_start "spark://#{master_ip}:#{node['hadoop_spark']['master']['port']}" do
  worker_id found_id
  action :start_worker
end

homedir = node['hadoop_spark']['user'].eql?("root") ? "/root" : "/home/#{node['hadoop_spark']['user']}"

kagent_keys "#{homedir}" do
  cb_user "#{node['hadoop_spark']['user']}"
  cb_group "#{node['hadoop_spark']['group']}"
  cb_name "hadoop_spark"
  cb_recipe "master"  
  action :get_publickey
end  
