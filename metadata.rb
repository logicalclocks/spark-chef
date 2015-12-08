name             'spark'
maintainer       "Jim Dowling"
maintainer_email "jdowling@kth.se"
license          "Apache v2"
description      'Installs/Configures Spark'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "1.0"

depends          "kagent"
depends          "hops"
depends          "hadoop"
depends          "java"

recipe           "install", "Installs Spark binaries"
recipe           "master", "Starts a Spark master"
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

attribute "spark/scala/version",
:description => "Version of scala to install",
:type => 'string'

attribute "spark/master/port",
:description => "Port for Master UI",
:type => 'string'

attribute "spark/worker/webui_port",
:description => "Port for Worker Web UI",
:type => 'string'

