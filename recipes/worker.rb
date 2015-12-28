
master_ip = private_recipe_ip("spark","master")

# Generate a unique id for each worker using the list of ip addresses
# for the workers.
# Get the ip address of this worker. Then find the offset of this worker in the
# list of private_ips set by karamel. The offset of 'my_ip' is the worker_id.
my_ip = my_private_ip()
found_id = -1
id = 1
for worker in node[:spark][:worker][:private_ips]
  if my_ip.eql? worker
    Chef::Log.info "Found matching IP address in the list of nodes: #{worker} . ID= #{id}"
    found_id = id
  end
  id += 1
end 

if found_id == -1
   Chef::Log.fatal "Could not find matching IP address in list the spark workers."
end


spark_start "spark://#{master_ip}:#{node[:spark][:master][:port]}" do
  worker_id found_id
  action :start_worker
end

homedir = node[:spark][:user].eql?("root") ? "/root" : "/home/#{node[:spark][:user]}"

kagent_keys "#{homedir}" do
  cb_user "#{node[:spark][:user]}"
  cb_group "#{node[:spark][:group]}"
  cb_name "spark"
  cb_recipe "master"  
  action :get_publickey
end  
