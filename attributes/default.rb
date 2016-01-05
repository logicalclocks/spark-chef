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

default[:spark][:yarn]                      = "false"

node.default.spark.yarn.applicationMaster.waitTries     = 10
node.default.spark.yarn.submit.file.replication         = 3
node.default.spark.yarn.preserve.staging.files          = "false"
node.default.spark.yarn.scheduler.heartbeat.interval-ms = 5000
#node.default.spark.yarn.max.executor.failures           = 3
#node.default.spark.yarn.historyServer.address
node.default.spark.yarn.queue                           = "default"
# the Spark jar can  be in a world-readable location on HDFS. This allows YARN to cache it on nodes so that it doesn't need to be distributed each time an application runs.
# The path given is the full hdfs path, without the protocol prefix ( hdfs://)
node.default.spark.yarn.jar                             =  "/#{node.spark.user}/spark.jar"
node.default.spark.yarn.dist.archives                   = ""
node.default.spark.yarn.dist.files                      = ""
node.default.spark.yarn.am.memory                       = "512m"
node.default.spark.yarn.containerLauncherMaxThreads     = 25

# Hash of environment variables
node.default.spark.yarn.appMasterEnv                    = {}
