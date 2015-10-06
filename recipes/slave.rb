
master_ip = private_recipe_ip("spark","master")

# Generate a unique id for each slave using the list of ip addresses
# for the slaves.
# Get the ip address of this slave. Then find the offset of this slave in the
# list of private_ips set by karamel. The offset of 'my_ip' is the slave_id.
my_ip = my_private_ip()
found_id = -1
id = 1
for slave in node[:spark][:slave][:private_ips]
  if my_ip.eql? slave
    Chef::Log.info "Found matching IP address in the list of nodes: #{slave} . ID= #{id}"
    found_id = id
  end
  id += 1
end 

if found_id == -1
   Chef::Log.fatal "Could not find matching IP address in list the spark slaves."
end


spark_start "spark://#{master_ip}:#{node[:spark][:master][:port]}" do
  slave_id found_id
  action :start_slave
end

homedir = node[:spark][:user].eql?("root") ? "/root" : "/home/#{node[:spark][:user]}"

spark_master "#{homedir}" do
  action :get_publickey
end
