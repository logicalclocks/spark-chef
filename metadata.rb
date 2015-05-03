name             'spark'
maintainer       "Jim Dowling"
maintainer_email "jdowling@kth.se"
license          "Apache v2"
description      'Installs/Configures Spark'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "1.0"

depends          "hadoop"
depends          "kagent"

recipe           "install", "Installs Spark binaries"
recipe           "master", "Starts a Spark master"
recipe           "slave", "Starts a Spark slave"
recipe           "yarn", "Install for yarn"


attribute "spark/executor_memory",
:display_name => "Executor memory (e.g., 512m)",
:type => 'string',
:default => '512m'

attribute "spark/driver_memory",
:display_name => "Driver memory (e.g., 1g)",
:type => 'string',
:default => '1g'

attribute "spark/eventlog_enabled",
:display_name => "Eventlog enabled (true|false)",
:type => 'string',
:default => 'false'

attribute "spark/worker/cleanup/enabled",
:display_name => "Spark standalone worker cleanup enabled (true|false)",
:type => 'string',
:default => 'true'



