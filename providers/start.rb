action :start_master do

  bash "start-master" do
    user node[:spark][:user]
    group node[:spark][:group]
    cwd node[:spark][:base_dir]
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
    user node[:spark][:user]
    group node[:spark][:group]
    cwd node[:spark][:base_dir]
    code <<-EOF
     
    ./sbin/start-slave.sh #{new_resource.master_url}
     if [ $? -ne 0 ] ; then
         ./sbin/stop-slave.sh
         ./sbin/start-slave.sh #{new_resource.master_url}
     fi
    EOF
  end
 
end
