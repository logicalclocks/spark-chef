libpath = File.expand_path '../../../kagent/libraries', __FILE__

master_ip = private_recipe_ip("spark","master")

spark_start "spark://#{master_ip}:#{node[:spark][:master][:port]}" do
  action :start_slave
end

