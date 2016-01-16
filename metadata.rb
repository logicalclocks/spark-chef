name             'spark'
maintainer       "Jim Dowling"
maintainer_email "jdowling@kth.se"
license          "Apache v2"
description      'Installs/Configures Spark'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "1.0"

depends          "kagent"
depends          "hadoop"
depends          "java"
depends          "hops"

recipe           "install", "Installs Spark binaries"
#link:<a target='_blank' href='http://%host%:8080/'>Launch the WebUI for the Spark Master</a>
recipe           "master", "Starts a Spark master"
#link:<a target='_blank' href='http://%host%:8081/'>Launch the WebUI for the Spark Slave %host%</a>
recipe           "worker", "Starts a Spark worker"
recipe           "yarn", "Install for yarn"


attribute "spark/user",
:description => "Username to run spark master/worker as",
:type => 'string'

attribute "spark/group",
:description => "Groupname to run spark master/worker as",
:type => 'string'

attribute "spark/executor_memory",
:description => "Executor memory (e.g., 512m)",
:type => 'string',
:required => "required"

attribute "spark/driver_memory",
:description => "Driver memory (e.g., 1g)",
:type => 'string',
:required => "required"

attribute "spark/eventlog_enabled",
:description => "Eventlog enabled (true|false)",
:type => 'string'

attribute "spark/worker/cleanup/enabled",
:description => "Spark standalone worker cleanup enabled (true|false)",
:type => 'string'

attribute "spark/eventlog_enabled",
:description => "Eventlog enabled (true|false)",
:type => 'string'

attribute "spark/hadoop/distribution",
:description => "Hadoop distribution (hops|apache)",
:type => 'string'

attribute "spark/master/port",
:description => "Port for Master UI",
:type => 'string'

attribute "spark/worker/webui_port",
:description => "Port for Worker Web UI",
:type => 'string'

attribute "spark/dir",
:description => "Installation directory for Spark",
:type => 'string'
