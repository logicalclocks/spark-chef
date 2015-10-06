action :return_publickey do
 homedir = "#{new_resource.homedir}"
 contents = ::IO.read("#{homedir}/.ssh/id_rsa.pub")
 Chef::Log.info "Public key read is: #{contents}"
 node.default[:spark][:master][:public_key] = "#{contents}"

# This works for chef-solo - we are executing this recipe.rb file.
 recipeName = "#{__FILE__}".gsub(/.*\//, "")
 recipeName = "#{recipeName}".gsub(/\.rb/, "")

 Chef::Log.info "Recipe name is #{recipeName}"

  template "#{homedir}/.ssh/config" do
    source "ssh_config.erb"
    owner node[:spark][:user]
    group node[:spark][:group]
    mode 0600
  end
 
 kagent_param "/tmp" do
   executing_cookbook "spark"
   executing_recipe  "master"
   cookbook "spark"
   recipe "master"
   param "public_key"
   value  node[:spark][:master][:public_key]
 end
end

action :get_publickey do
  homedir = "#{new_resource.homedir}"

  Chef::Log.info "JobMgr public key read is: #{node[:spark][:master][:public_key]}"
  bash "add_jobmgr_public_key" do
    user node[:spark][:user]
    group node[:spark][:group]
    code <<-EOF
      mkdir #{homedir}/.ssh
      echo "#{node[:spark][:master][:public_key]}" >> #{homedir}/.ssh/authorized_keys
      touch #{homedir}/.ssh/.jobmgr_key_authorized
  EOF
    not_if { ::File.exists?( "#{homedir}/.ssh/.jobmgr_key_authorized" || "#{node[:spark][:master][:public_key]}".empty? ) }
  end
end
