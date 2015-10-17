bash 'kill_running_service_spark' do
    user "root"
    ignore_failure :true
    code <<-EOF
      pkill Master
      pkill Slave
    EOF
end


directory node[:spark][:home] do
  recursive true
  action :delete
  ignore_failure :true
end

link node[:spark][:base_dir] do
  action :delete
  ignore_failure :true
end


