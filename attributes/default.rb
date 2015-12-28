include_attribute "kagent"
include_attribute "hops"
include_attribute "hadoop"

default[:spark][:user]                      = "spark"
default[:spark][:group]                     = "#{node[:hadoop][:group]}"

default[:spark][:version]                   = "1.5.2"
default[:spark][:hadoop][:version]          = "2.4"
default[:spark][:scala][:version] 	    = "2.11"
default[:spark][:dir]                       = "/srv"
default[:spark][:base_dir]                  = "#{node[:spark][:dir]}/spark"
default[:spark][:home]                      = "#{node[:spark][:dir]}/spark-#{node[:spark][:version]}-bin-hadoop#{node[:spark][:hadoop][:version]}"
default[:spark][:url]                       = "#{node[:download_url]}/spark-#{node[:spark][:version]}-bin-hadoop#{node[:spark][:hadoop][:version]}.tgz"

default[:spark][:executor_memory]           = "512m"
default[:spark][:driver_memory]             = "1g"
default[:spark][:eventlog_enabled]          = "false"
default[:spark][:driver][:maxResultSize]    = "1g"

default[:spark][:master][:port]             = 7077
default[:spark][:worker][:webui_port]       = 9091


default[:spark][:worker][:cleanup][:enabled]= true

# Pick hadoop distribution. Options are 'hops' and 'hadoop'
default[:spark][:hadoop][:distribution]     = "hadoop"

default[:spark][:master][:public_key]       = ""
