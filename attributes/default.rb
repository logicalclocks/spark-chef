include_attribute "kagent"
include_attribute "hops"
include_attribute "hadoop"


default.hadoop_spark.user                      = "spark"
default.hadoop_spark.group                     = "#{node.apache_hadoop.group}"

default.hadoop_spark.version                   = "1.5.2"
default.hadoop_spark.hadoop.version            = "2.4"
default.scala.version 	                       = "2.10"
default.hadoop_spark.dir                       = "/srv"
default.hadoop_spark.base_dir                  = "#{node.hadoop_spark.dir}/spark"
default.hadoop_spark.home                      = "#{node.hadoop_spark.dir}/spark-#{node.hadoop_spark.version}-bin-hadoop#{node.hadoop_spark.hadoop.version}"
default.hadoop_spark.url                       = "#{node.download_url}/spark-#{node.hadoop_spark.version}-bin-hadoop#{node.hadoop_spark.hadoop.version}.tgz"

default.hadoop_spark.executor_memory           = "512m"
default.hadoop_spark.driver_memory             = "1g"
default.hadoop_spark.eventlog_enabled          = "false"
default.hadoop_spark.driver.maxResultSize      = "1g"

default.hadoop_spark.master.port               = 7077

default.hadoop_spark.worker.cleanup.enabled= true

# Pick hadoop distribution. Options are 'hops' and 'apache_hadoop'
default.hadoop_spark.hadoop.distribution       = "apache_hadoop"

default.hadoop_spark.master.public_key         = ""

node.default.java.jdk_version                  = 7


# Pick hadoop distribution. Options are 'hops' and 'hadoop'
default.spark.hadoop.distribution                  = "hadoop"
default.spark.master.public_key                    = ""
default.spark.yarn.support                         = "false"
default.spark.authenticate.secret                  = ""
default.spark.yarn.applicationMaster.waitTries     = 10
default.spark.yarn.submit.file.replication         = 3
default.spark.yarn.preserve.staging.files          = "false"
default.spark.yarn.scheduler.heartbeat.interval_ms = 5000
default.spark.yarn.queue                           = "default"
# the Spark jar can  be in a world-readable location on HDFS. This allows YARN to cache it on nodes so that it doesn't need to be distributed each time an application runs.
# The path given is the full hdfs path, without the protocol prefix ( hdfs://)
default.spark.yarn.jar                             =  "/user/#{node.spark.user}/spark.jar"
default.spark.yarn.dist.archives                   = ""
default.spark.yarn.dist.files                      = ""
default.spark.yarn.am.memory                       = "512m"
default.spark.yarn.containerLauncherMaxThreads     = 25
#default.spark.yarn.am.waitTime                     = "100s"
#default.spark.yarn.max.executor.failures           = 3
#default.spark.yarn.historyServer.address

# Hash of environment variables
default.spark.yarn.appMasterEnv                    = {}
