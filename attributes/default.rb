include_attribute "kagent"
include_attribute "hops"
include_attribute "hopsmonitor"
include_attribute "hive2"
include_attribute "elastic"

default['hadoop_spark']['user']                                 = node['install']['user'].empty? ? "spark" : node['install']['user']

default['hadoop_spark']['version']                              = "2.4.3.2"
default['scala']['version'] 	                                = "2.11"
default['hadoop_spark']['dir']                                  = node['install']['dir'].empty? ? "/srv/hops" : node['install']['dir']
default['hadoop_spark']['base_dir']                             = "#{node['hadoop_spark']['dir']}/spark"
default['hadoop_spark']['home']                                 = "#{node['hadoop_spark']['dir']}/spark-#{node['hadoop_spark']['version']}-bin-without-hadoop-with-hive-with-r"
default['hadoop_spark']['conf_dir']                             = "#{node['hadoop_spark']['base_dir']}/conf"
default['hadoop_spark']['sbin_dir']                             = "#{node['hadoop_spark']['base_dir']}/sbin"
default['hadoop_spark']['hopsworks_jars']                       = "#{node['hadoop_spark']['base_dir']}/hopsworks-jars"
default['hadoop_spark']['url']                                  = "#{node['download_url']}/spark-#{node['hadoop_spark']['version']}-bin-without-hadoop-with-hive-with-r.tgz"

default['hadoop_spark']['spark_sql_dependencies_url']           = "#{node['download_url']}/spark-sql-dependencies"
default['hadoop_spark']['parquet_version']                      = "1.10.0"
default['hadoop_spark']['parquet_format_version']               = "2.6.0"
default['hadoop_spark']['executor_memory']                      = "512m"
default['hadoop_spark']['driver_memory']                        = "1g"
default['hadoop_spark']['eventlog_enabled']                     = "true"
default['hadoop_spark']['driver']['maxResultSize']                 = "512m"
default['hadoop_spark']['io']['compression']['codec']              = "snappy"
default['hadoop_spark']['streaming']['stopGracefullyOnShutdown']   = "true"
default['hadoop_spark']['master']['port']                          = 7077

default['hadoop_spark']['worker']['cleanup']['enabled']= true

default['hadoop_spark']['historyserver']['port']                   = 18080


# Pick hadoop distribution. Options are 'hops' and 'hadoop'
default['hadoop_spark']['hadoop']['distribution']                  = "hops"
default['hadoop_spark']['master']['public_key']                    = ""
default['hadoop_spark']['yarn']['support']                         = "false"
default['hadoop_spark']['authenticate']['secret']                  = ""
default['hadoop_spark']['yarn']['am']['waitTime']                  = "100s"
default['hadoop_spark']['yarn']['submit']['file']['replication']   = 3
default['hadoop_spark']['yarn']['preserve']['staging']['files']    = "false"
default['hadoop_spark']['yarn']['scheduler']['heartbeat']['interval_ms'] = 5000
default['hadoop_spark']['yarn']['queue']                           = "default"
# the Spark jar can  be in a world-readable location on HDFS. This allows YARN to cache it on nodes so that it doesn't need to be distributed each time an application runs.
# The path given is the full hdfs path, without the protocol prefix ( hdfs://)
default['hadoop_spark']['yarn']['pyspark_archive']                 =  "pyspark.zip"
default['hadoop_spark']['yarn']['py4j_archive']                    =  "py4j-0.10.7-src.zip"
default['hadoop_spark']['yarn']['warehouse_hdfs']                  =  "/user/#{node['hadoop_spark']['user']}/spark-warehouse"
default['hadoop_spark']['yarn']['pyspark_archive_hdfs']            =  "/user/#{node['hadoop_spark']['user']}/#{node['hadoop_spark']['yarn']['pyspark_archive']}"
default['hadoop_spark']['yarn']['py4j_archive_hdfs']               =  "/user/#{node['hadoop_spark']['user']}/#{node['hadoop_spark']['yarn']['py4j_archive']}"
# Use comma to separate multiple archives, and use # to create the symlink on YARN runtime working directory.
default['hadoop_spark']['yarn']['dist']['archives']                = ""
default['hadoop_spark']['yarn']['dist']['files']                   = ""
#default.hadoop_spark.yarn.dist.jars                               = ""
default['hadoop_spark']['pyFiles']                                 = "local://#{node['hadoop_spark']['base_dir']}/python/lib/pyspark.zip"
default['hadoop_spark']['yarn']['jars']                            = "local://#{node['hadoop_spark']['base_dir']}/jars/*"
default['hadoop_spark']['yarn']['am']['memory']                    = "512m"
default['hadoop_spark']['yarn']['containerLauncherMaxThreads']     = 25
default['hadoop_spark']['yarn']['private_ips']                     = []
#default.spark.yarn.am.waitTime                           = "100s"
#default.spark.yarn.max.executor.failures                 = 3
#default.spark.yarn.historyServer.address
default['hadoop_spark']['yarn']['am']['attemptFailuresValidityInterval'] = "1h"

# Hash of environment variables
default['hadoop_spark']['yarn']['appMasterEnv']                    = {}


default['hadoop_spark']['history']['fs']['cleaner']['enabled']     = "true"
default['hadoop_spark']['history']['fs']['cleaner']['interval']    = "1d"
default['hadoop_spark']['history']['fs']['cleaner']['maxAge']      = "7d"

#
# Parameters taken from here: http://www.slideshare.net/jcmia1/apache-spark-20-tuning-guide
# 5g is a learned parameter from 1TB benchmarks
#
default['hadoop_spark']['driver']['maxResultSize']                = "5g"
default['hadoop_spark']['daemon']['memory']                       = "4g"
default['hadoop_spark']['sql']['broadcastTimeout']                = "1200"
default['hadoop_spark']['sql']['networkTimeout']                  = "700"

default['hadoop_spark']['ciphers'] 		      		  = "TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256,TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256,TLS_RSA_WITH_AES_128_CBC_SHA256,TLS_ECDH_ECDSA_WITH_AES_128_CBC_SHA256,TLS_ECDH_RSA_WITH_AES_128_CBC_SHA256,TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA,TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA,TLS_RSA_WITH_AES_128_CBC_SHA,TLS_ECDH_ECDSA_WITH_AES_128_CBC_SHA,TLS_ECDH_RSA_WITH_AES_128_CBC_SHA,TLS_ECDHE_ECDSA_WITH_3DES_EDE_CBC_SHA,TLS_ECDHE_RSA_WITH_3DES_EDE_CBC_SHA,TLS_ECDH_ECDSA_WITH_3DES_EDE_CBC_SHA,TLS_ECDH_RSA_WITH_3DES_EDE_CBC_SHA"
default['hadoop_spark']['ssl_enabled']          		  = "true"
default['hadoop_spark']['ssl']['protocol'] 			  = "TLSv1,TLSv1.1,TLSv1.2"
default['hadoop_spark']['ssl']['keystorepassword']		  = "#{node['hopsworks']['master']['password']}"
default['hadoop_spark']['ssl']['truststorepassword']		  = "#{node['hopsworks']['master']['password']}"

default['hopsmonitor']['default']['private_ips']                  = ['10.0.2.15']
default['hopslog']['default']['private_ips']                      = ['10.0.2.15']
default['hopsworks']['domain_truststore_path']                    = "#{node['hopsworks']['domain_truststore_path']}"
default['hopsworks']['domain_truststore']                         = "#{node['hopsworks']['domain_truststore']}"

#
# Hops API jar
#
default['hadoop_spark']['hopsutil_version']                    = node['install']['version']
default['hadoop_spark']['hopsutil']['url']                     = "#{node['download_url']}/hopsutil/#{node['hadoop_spark']['hopsutil_version']}/hops-util-#{node['hadoop_spark']['hopsutil_version']}.jar"

#
# Hops Examples Spark Job/Notebook Dependency Jars
#
default['hadoop_spark']['hopsexamples_version']                     = node['install']['version']
default['hadoop_spark']['hopsexamples_spark']['url']                = "#{node['download_url']}/hopsexamples/#{node['hadoop_spark']['hopsexamples_version']}/hops-examples-spark-#{node['hadoop_spark']['hopsexamples_version']}.jar"
default['hadoop_spark']['hopsexamples_hive']['url']                 = "#{node['download_url']}/hopsexamples/#{node['hadoop_spark']['hopsexamples_version']}/hops-examples-hive-#{node['hadoop_spark']['hopsexamples_version']}.jar"
default['hadoop_spark']['hopsexamples_featurestore_tour']['url']    = "#{node['download_url']}/hopsexamples/#{node['hadoop_spark']['hopsexamples_version']}/hops-examples-featurestore-tour-#{node['hadoop_spark']['hopsexamples_version']}.jar"


#
# Featurestore dependencies
#
default['hadoop_spark']['spark_avro_version']               = "2.11-2.4.3.2"
default['hadoop_spark']['tf_spark_connector_version']       = "2.11-1.12.0"
default['hadoop_spark']['spark_tfrecord_version']           = "2.11-0.1.1"
default['hadoop_spark']['mysql_driver']                     = "#{node['download_url']}/mysql-connector-java-8.0.21-bin.jar"

default['hadoop_spark']['hsfs']['version']                  = "2.2.20"
default['hadoop_spark']['hsfs']['url']                      = "#{node['download_url']}/hsfs/#{node['hadoop_spark']['hsfs']['version']}/hsfs-#{node['hadoop_spark']['hsfs']['version']}.jar"

default['hadoop_spark']['hsfs']['utils']['version']         = "2.2.20"
default['hadoop_spark']['hsfs']['utils']['download_url']    = "#{node['download_url']}/hsfs_utils/hsfs_utils-#{node['hadoop_spark']['hsfs']['utils']['version']}.py"

#
# Hudi Dependencies
#
default['hadoop_spark']['hudi_bundle_url']                               = "#{node['download_url']}/hudi/#{node['hive2']['hudi_version']}/hudi-spark-bundle-#{node['hive2']['hudi_version']}.jar"

#
# Delta
#
default['hadoop_spark']['databricks_delta_version']                          = "2.11-0.3.0"

# Spark elastic connector
default['hadoop_spark']['elastic_connector']['url']                          = "#{node['download_url']}/elasticsearch-spark-20_2.11-#{node['elastic']['version']}.jar"

# Prometheus exporter
default['hadoop_spark']['spark-metrics_version']        = "#{node['scala']['version']}-2.4-1.0.5"
default['hadoop_spark']['simpleclient_version']         = "0.8.1"
default['hadoop_spark']['metrics-core_version']         = "3.1.5"

default['hadoop_spark']['snowflake-jdbc_version']       = "3.12.17"
default['hadoop_spark']['spark-snowflake_artifactID']   = "2.11"  
default['hadoop_spark']['spark-snowflake_version']      = "2.8.4-spark_2.4"

default['hadoop_spark']['snowflake-jdbc']['url']        = "#{node['download_url']}/snowflake/snowflake-jdbc-#{node['hadoop_spark']['snowflake-jdbc_version']}.jar"
default['hadoop_spark']['spark-snowflake']['url']       = "#{node['download_url']}/snowflake/spark-snowflake_#{node['hadoop_spark']['spark-snowflake_artifactID']}-#{node['hadoop_spark']['spark-snowflake_version']}.jar"
