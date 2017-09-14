daemons = %w{Master Worker sparkhistoryserver}
daemons.each { |d| 

  bash 'kill_running_service_#{d}' do
    user "root"
    ignore_failure true
    code <<-EOF
      service stop #{d}
      systemctl stop #{d}
      pkill -9 #{d}
    EOF
  end

  file "/etc/init.d/#{d}" do
    action :delete
    ignore_failure true
  end
  
  file "/usr/lib/systemd/system/#{d}.service" do
    action :delete
    ignore_failure true
  end
  file "/lib/systemd/system/#{d}.service" do
    action :delete
    ignore_failure true
  end
}

directory node['hadoop_spark']['home'] do
  recursive true
  action :delete
  ignore_failure true
end

link node['hadoop_spark']['base_dir'] do
  action :delete
  ignore_failure true
end


package_url = "#{node['hadoop_spark']['url']}"
base_package_filename = File.basename(package_url)
cached_package_filename = "/tmp/#{base_package_filename}"

file cached_package_filename do
  action :delete
  ignore_failure true
end

