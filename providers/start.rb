action :start_master do

  bash "start-master" do
    user node[:spark][:user]
    group node[:spark][:group]
    code <<-EOF
     #{node[:spark][:home]}/sbin/start-master.sh
    EOF
  end
 
end


action :start_slave do

  bash "start-slave" do
    user node[:spark][:user]
    group node[:spark][:group]
    code <<-EOF
#    #{node[:spark][:home]}/sbin/start-slave.sh --properties-file #{node[:spark][:home]}/conf/spark-defaults.conf
    cd #{node[:spark][:home]}
    ./sbin/start-slave.sh #{new_resource.slave_id} #{new_resource.master_url}
    EOF
#    not_if "#{node[:spark][:home]}/sbin/start-slave.sh --properties-file #{node[:spark][:home]}/conf/spark-defaults.conf | grep \"stop it first\""
  end
 
end
