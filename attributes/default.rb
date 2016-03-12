include_attribute "kagent"

default.hadoop_spark.user                      = "spark"
default.hadoop_spark.group                     = "#{node.apache_hadoop.group}"

default.hadoop_spark.version                   = "1.6.0"
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
