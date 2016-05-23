include_attribute "kagent"
include_attribute "apache_hadoop"
include_attribute "hops"
include_attribute "hopsworks"

default.hadoop_spark.user                      = "spark"
default.hadoop_spark.group                     = "#{node.apache_hadoop.group}"

default.hadoop_spark.version                   = "1.6.1"
default.hadoop_spark.hadoop.version            = "2.4"
default.scala.version 	                       = "2.10"
default.hadoop_spark.dir                       = "/srv"
default.hadoop_spark.base_dir                  = "#{node.hadoop_spark.dir}/spark"
default.hadoop_spark.home                      = "#{node.hadoop_spark.dir}/spark-#{node.hadoop_spark.version}-bin-hadoop#{node.hadoop_spark.hadoop.version}"
default.hadoop_spark.url                       = "#{node.download_url}/spark-#{node.hadoop_spark.version}-bin-hadoop#{node.hadoop_spark.hadoop.version}.tgz"

default.hadoop_spark.executor_memory           = "512m"
default.hadoop_spark.driver_memory             = "1g"
default.hadoop_spark.eventlog_enabled          = "true"
default.hadoop_spark.driver.maxResultSize      = "512m"

default.hadoop_spark.master.port               = 7077

default.hadoop_spark.worker.cleanup.enabled= true


# Pick hadoop distribution. Options are 'hops' and 'apache_hadoop'
default.hadoop_spark.hadoop.distribution       = "apache_hadoop"

default.hadoop_spark.master.public_key         = ""

node.default.java.jdk_version                  = 7


# Pick hadoop distribution. Options are 'hops' and 'hadoop'
default.hadoop_spark.hadoop.distribution                  = "hops"
default.hadoop_spark.master.public_key                    = ""
default.hadoop_spark.yarn.support                         = "false"
default.hadoop_spark.authenticate.secret                  = ""
default.hadoop_spark.yarn.am.waitTime                     = "100s"
default.hadoop_spark.yarn.submit.file.replication         = 3
default.hadoop_spark.yarn.preserve.staging.files          = "false"
default.hadoop_spark.yarn.scheduler.heartbeat.interval_ms = 5000
default.hadoop_spark.yarn.queue                           = "default"
# the Spark jar can  be in a world-readable location on HDFS. This allows YARN to cache it on nodes so that it doesn't need to be distributed each time an application runs.
# The path given is the full hdfs path, without the protocol prefix ( hdfs://)
default.hadoop_spark.yarn.jar                             =  "/user/#{node.hadoop_spark.user}/spark.jar"
default.hadoop_spark.yarn.dist.archives                   = ""
default.hadoop_spark.yarn.dist.files                      = ""
default.hadoop_spark.yarn.am.memory                       = "512m"
default.hadoop_spark.yarn.containerLauncherMaxThreads     = 25
#default.spark.yarn.am.waitTime                     = "100s"
#default.spark.yarn.max.executor.failures           = 3
#default.spark.yarn.historyServer.address

# Hash of environment variables
default.hadoop_spark.yarn.appMasterEnv                    = {}
default.hadoop_spark.systemd                              = "true"


default.hadoop_spark.history.fs.cleaner.enabled           = "true"
default.hadoop_spark.history.fs.cleaner.interval          = "1d"
default.hadoop_spark.history.fs.cleaner.maxAge            = "7d"

default.hadoop_spark.ciphers 							  = "TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256,TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256,TLS_RSA_WITH_AES_128_CBC_SHA256,TLS_ECDH_ECDSA_WITH_AES_128_CBC_SHA256,TLS_ECDH_RSA_WITH_AES_128_CBC_SHA256,TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA,TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA,TLS_RSA_WITH_AES_128_CBC_SHA,TLS_ECDH_ECDSA_WITH_AES_128_CBC_SHA,TLS_ECDH_RSA_WITH_AES_128_CBC_SHA,TLS_ECDHE_ECDSA_WITH_3DES_EDE_CBC_SHA,TLS_ECDHE_RSA_WITH_3DES_EDE_CBC_SHA,TLS_ECDH_ECDSA_WITH_3DES_EDE_CBC_SHA,TLS_ECDH_RSA_WITH_3DES_EDE_CBC_SHA"
default.hadoop_spark.ssl_enabled          				  = "true"
default.hadoop_spark.ssl.protocol 						  = "TLS"
default.hadoop_spark.ssl.keystorepassword				  = "#{node.hopsworks.master.password}"