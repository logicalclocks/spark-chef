include_attribute "kagent"
include_attribute "apache_hadoop"
include_attribute "hops"

default.hadoop_spark.user                                 = "spark"
default.hadoop_spark.group                                = "#{node.apache_hadoop.group}"

default.hadoop_spark.version                              = "2.1.0"
default.scala.version 	                                  = "2.11"
default.hadoop_spark.dir                                  = "/srv"
default.hadoop_spark.base_dir                             = "#{node.hadoop_spark.dir}/spark"
default.hadoop_spark.home                                 = "#{node.hadoop_spark.dir}/spark-#{node.hadoop_spark.version}-bin-without-hadoop"
default.hadoop_spark.conf_dir                             = "#{node.hadoop_spark.base_dir}/conf"
default.hadoop_spark.url                                  = "#{node.download_url}/spark-#{node.hadoop_spark.version}-bin-without-hadoop.tgz"

default.hadoop_spark.executor_memory                      = "512m"
default.hadoop_spark.driver_memory                        = "1g"
default.hadoop_spark.eventlog_enabled                     = "true"
default.hadoop_spark.driver.maxResultSize                 = "512m"
default.hadoop_spark.io.compression.codec                 = "snappy"
default.hadoop_spark.streaming.stopGracefullyOnShutdown   = "true"
default.hadoop_spark.master.port                          = 7077

default.hadoop_spark.worker.cleanup.enabled= true

default.hadoop_spark.historyserver.port                   = 18080

# Pick hadoop distribution. Options are 'hops' and 'apache_hadoop'
default.hadoop_spark.hadoop.distribution                  = "hops"

default.hadoop_spark.master.public_key                    = ""

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
default.hadoop_spark.yarn.archive                         =  "spark-jars.zip"
default.hadoop_spark.yarn.archive_hdfs                    =  "/user/#{node.hadoop_spark.user}/spark-jars.zip"
default.hadoop_spark.yarn.warehouse_hdfs                  = "/user/#{node.hadoop_spark.user}/spark-warehouse"
# Use comma to separate multiple archives, and use # to create the symlink on YARN runtime working directory.
default.hadoop_spark.yarn.dist.archives                   = ""
default.hadoop_spark.yarn.dist.files                      = ""
#default.hadoop_spark.yarn.dist.jars                      = ""
default.hadoop_spark.pyFiles                              = "local://#{node.hadoop_spark.base_dir}/python/lib/pyspark.zip"
default.hadoop_spark.yarn.jars                            = "local://#{node.hadoop_spark.base_dir}/jars/*"
default.hadoop_spark.yarn.am.memory                       = "512m"
default.hadoop_spark.yarn.containerLauncherMaxThreads     = 25
#default.spark.yarn.am.waitTime                           = "100s"
#default.spark.yarn.max.executor.failures                 = 3
#default.spark.yarn.historyServer.address

# Hash of environment variables
default.hadoop_spark.yarn.appMasterEnv                    = {}
default.hadoop_spark.systemd                              = "true"


default.hadoop_spark.history.fs.cleaner.enabled           = "true"
default.hadoop_spark.history.fs.cleaner.interval          = "1d"
default.hadoop_spark.history.fs.cleaner.maxAge            = "7d"

#
# Parameters taken from here: http://www.slideshare.net/jcmia1/apache-spark-20-tuning-guide
# 5g is a learned parameter from 1TB benchmarks
#
default.hadoop_spark.driver.maxResultSize                 = "5g"
default.hadoop_spark.local.dir                            = "/tmp"
default.hadoop_spark.daemon.memory                        = "4g"
default.hadoop_spark.sql.broadcastTimeout                 = "1200"
default.hadoop_spark.sql.networkTimeout                   = "700"


