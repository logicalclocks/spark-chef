name             "hadoop_spark"
maintainer       "Jim Dowling"
maintainer_email "jdowling@kth.se"
license          "Apache v2"
description      'Installs/Configures Spark'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.1.1"

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


attribute "java/jdk_version",
:display_name =>  "Jdk version",
:type => 'string'

attribute "hadoop_spark/user",
:display_name => "Username to run spark master/worker as",
:type => 'string'

attribute "hadoop_spark/group",
:display_name => "Groupname to run spark master/worker as",
:type => 'string'

attribute "hadoop_spark/executor_memory",
:display_name => "Executor memory (e.g., 512m)",
:type => 'string'

attribute "hadoop_spark/driver_memory",
:display_name => "Driver memory (e.g., 1g)",
:type => 'string'

attribute "hadoop_spark/eventlog_enabled",
:display_name => "Eventlog enabled (true|false)",
:type => 'string'

attribute "hadoop_spark/worker/cleanup/enabled",
:display_name => "Spark standalone worker cleanup enabled (true|false)",
:type => 'string'

attribute "hadoop_spark/eventlog_enabled",
:display_name => "Eventlog enabled (true|false)",
:type => 'string'


attribute "hadoop_spark/version",
:display_name => "Spark version (e.g., 1.4.1 or 1.5.2)",
:type => 'string'

