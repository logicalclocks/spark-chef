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

recipe           "install", "Installs Spark binaries"
recipe           "master", "Starts a Spark master"
recipe           "worker", "Starts a Spark worker"
recipe           "yarn", "Install for yarn"


attribute "spark/user",
:display_name => "Username to run spark master/worker as",
:type => 'string'

attribute "spark/group",
:display_name => "Groupname to run spark master/worker as",
:type => 'string'

attribute "spark/executor_memory",
:display_name => "Executor memory (e.g., 512m)",
:type => 'string',
:required => "required"

attribute "spark/driver_memory",
:display_name => "Driver memory (e.g., 1g)",
:type => 'string',
:required => "required"

attribute "spark/eventlog_enabled",
:display_name => "Eventlog enabled (true|false)",
:type => 'string'

attribute "spark/worker/cleanup/enabled",
:display_name => "Spark standalone worker cleanup enabled (true|false)",
:type => 'string'

attribute "spark/eventlog_enabled",
:display_name => "Eventlog enabled (true|false)",
:type => 'string'

attribute "spark/hadoop/distribution",
:display_name => "Hadoop distribution (hops|apache)",
:type => 'string'

