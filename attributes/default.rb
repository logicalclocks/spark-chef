include_attribute "kagent"
include_attribute "hadoop"

default[:spark][:version]                   = "1.2.0"
default[:hadoop][:version]                  = "2.4"
default[:scala][:version] 	            = "2.10"
default[:spark][:user]                      = "#{node[:hadoop][:yarn][:user]}"
default[:spark][:group]                     = "#{node[:hadoop][:group]}"
default[:spark][:dir]                       = "/srv"
default[:spark][:base_dir]                  = "#{node[:spark][:dir]}/spark"
default[:spark][:home]                      = "#{node[:spark][:dir]}/spark-#{node[:spark][:version]}-bin-hadoop#{node[:hadoop][:version]}"
default[:spark][:url]                       = "#{node[:download_url]}/spark-#{node[:spark][:version]}-bin-hadoop#{node[:hadoop][:version]}.tgz"

default[:spark][:executor_memory]           = "512m"
default[:spark][:driver_memory]             = "1g"
default[:spark][:eventlog_enabled]          = "false"
default[:spark][:driver][:maxResultSize]    = "1g"

default[:spark][:worker][:cleanup][:enabled] = true
