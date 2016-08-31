name             "hadoop_spark"
maintainer       "Jim Dowling"
maintainer_email "jdowling@kth.se"
license          "Apache v2"
description      'Installs/Configures Spark'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.1.2"
source_url       "https://github.com/hopshadoop/spark-chef"

depends          "kagent"
depends          "apache_hadoop"
depends          "java"
depends          "hops"
depends          "scala"

recipe           "install", "Installs Spark binaries"
#link:<a target='_blank' href='http://%host%:8080/'>Launch the WebUI for the Spark Master</a>
recipe           "master", "Starts a Spark master"
#link:<a target='_blank' href='http://%host%:8081/'>Launch the WebUI for the Spark Slave %host%</a>
recipe           "worker", "Starts a Spark worker"
recipe           "yarn", "Install for yarn"
recipe           "historyserver", "Installs/starts the Spark historyserver"

attribute "java/jdk_version",
          :description =>  "Jdk version",
          :type => 'string'

attribute "java/install_flavor",
          :description =>  "Oracle (default) or openjdk",
          :type => 'string'

attribute "hadoop_spark/user",
          :description => "Username to run spark master/worker as",
          :type => 'string'

attribute "hadoop_spark/group",
          :description => "Groupname to run spark master/worker as",
          :type => 'string'

attribute "hadoop_spark/executor_memory",
          :description => "Executor memory (e.g., 512m)",
          :type => 'string'

attribute "hadoop_spark/driver_memory",
          :description => "Driver memory (e.g., 1g)",
          :type => 'string'

attribute "hadoop_spark/eventlog_enabled",
          :description => "Eventlog enabled (true|false)",
          :type => 'string'

attribute "hadoop_spark/worker/cleanup/enabled",
          :description => "Spark standalone worker cleanup enabled (true|false)",
          :type => 'string'

attribute "hadoop_spark/version",
          :description => "Spark version (e.g., 1.4.1 or 1.5.2 or 1.6.0)",
          :type => 'string'

attribute "hadoop_spark/hadoop/distribution",
          :description => "'hops' or 'apache_hadoop'",
          :type => 'string'

attribute "hadoop_spark/history/fs/cleaner/enabled",
          :description => "'true' to enable cleanup of the historyservers logs",
          :type => 'string'

attribute "hadoop_spark/history/fs/cleaner/interval",
          :description => "How often to run the cleanup of the historyservers logs (e.g., '1d' for once per day)",
          :type => 'string'

attribute "hadoop_spark/history/fs/cleaner/maxAge",
          :description => "Age in days of the historyservers logs before they are removed (e.g., '7d' for 7 days)",
          :type => 'string'


