name             "hadoop_spark"
maintainer       "Jim Dowling"
maintainer_email "jdowling@kth.se"
license          "Apache v2"
description      'Installs/Configures Spark'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "3.0.0"
source_url       "https://github.com/hopshadoop/spark-chef"

depends 'magic_shell', '~> 1.0.0'
depends 'conda'
depends 'kagent'
depends 'ndb'
depends 'hops'
depends 'hive2'
depends 'hopsmonitor'
depends 'java'

recipe           "install", "Installs Spark binaries"
#link:<a target='_blank' href='http://%host%:8080/'>Launch the WebUI for the Spark Master</a>
recipe           "master", "Starts a Spark master"
#link:<a target='_blank' href='http://%host%:8081/'>Launch the WebUI for the Spark Slave %host%</a>
recipe           "worker", "Starts a Spark worker"
recipe           "yarn", "Creates directories for yarn. Run on only one machine."
recipe           "default", "Install spark binaries only."
recipe           "libs", "Install spark jars to nodemanager hosts"
recipe           "historyserver", "Installs/starts the Spark historyserver"

attribute "hadoop_spark/user",
          :description => "Username to run spark master/worker as",
          :type => 'string'

attribute "hadoop_spark/user_id",
          :description => "Spark user id. Default: 1505",
          :type => 'string'

attribute "hadoop_spark/dir",
          :description => "Installation dir for spark",
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

attribute "hadoop_spark/streaming/stopGracefullyOnShutdown",
          :description => "Shut down the StreamingContext gracefully on JVM shutdown rather than immediately (true|false)",
          :type => 'string'

attribute "hadoop_spark/worker/cleanup/enabled",
          :description => "Spark standalone worker cleanup enabled (true|false)",
          :type => 'string'

attribute "hadoop_spark/version",
          :description => "Spark version (e.g., 1.6.1 or 2.0.1 or 3.0.0)",
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

attribute "hadoop_spark/yarn/am/attemptFailuresValidityInterval",
          :description => "Defines the validity interval for AM failure tracking. If the AM has been running for at least the defined interval, the AM failure count will be reset.",
          :type => 'string'

attribute "hadoop_spark/driver/maxResultSize",
          :description => "Default '5g'. Change to '1g', '500m', etc",
          :type => 'string'

attribute "hadoop_spark/historyserver/private_ips",
          :description => "historyserver ip addr",
          :type => 'array'

attribute "install/dir",
          :description => "Set to a base directory under which we will install.",
          :type => "string"

attribute "install/user",
          :description => "User to install the services as",
          :type => "string"

attribute "hopslog/default/private_ips",
          :description => "elk services ip",
          :type => "string"

attribute "hadoop_spark/tf_spark_connector_version",
          :description => "the version of the tf-spark-connector .jar",
          :type => "string"

attribute "hadoop_spark/spark_tfrecord_version",
          :description => "the version of the spark-tfrecord library .jar",
          :type => "string"

attribute "hadoop_spark/hopsutil_version",
          :description => "the version of the hops-library .jar",
          :type => "string"

attribute "hadoop_spark/hopsutil/url",
          :description => "the url for dowloading the hopsutil .jar",
          :type => "string"

attribute "hadoop_spark/hopsexamples_version",
          :description => "the version of the hops-examples artifacts",
          :type => "string"

attribute "hadoop_spark/hopsexamples_spark/url",
          :description => "the url for dowloading the hopsexamples_spark jar",
          :type => "string"

attribute "hadoop_spark/hopsexamples_hive/url",
          :description => "the url for dowloading the hopsexamples_hive jar",
          :type => "string"

attribute "hadoop_spark/hopsexamples_featurestore_tour/url",
          :description => "the url for dowloading the hopsexamples_featurestore_tour jar",
          :type => "string"

attribute "hadoop_spark/spark_avro_version",
          :description => "the version of the spark-avro jar",
          :type => "string"


attribute "hadoop_spark/hopsexamples_featurestore_util4j/url",
          :description => "the url for dowloading the hopsexamples_featurestore_util4j jar",
          :type => "string"

attribute "hadoop_spark/hopsexamples_featurestore_util_py/url",
          :description => "the url for dowloading the hopsexamples_featurestore_util_py python file",
          :type => "string"

attribute "hadoop_spark/databricks_delta_version",
          :description => "the version of the databricks delta jar",
          :type => "string"

attribute "hadoop_spark/url",
          :description => "the url for downloading the spark tgz",
          :type => "string"

attribute "hadoop_spark/hsfs/version",
          :description => "Version of the HSFS library",
          :type => "string"

attribute "hadoop_spark/hsfs/url",
          :description => "URL from where to download the HSFS library",
          :type => "string"

attribute "hadoop_spark/snowflake-jdbc/version",
          :description => "Version of the snowflake jdbc driver",
          :type => "string"

attribute "hadoop_spark/snowflake-jdbc/url",
          :description => "URL from where to download the snowflake jdbc driver",
          :type => "string"

attribute "hadoop_spark/spark-snowflake/artifactID",
          :description => "Artifact id of the spark-snowflake connector",
          :type => "string"

attribute "hadoop_spark/spark-snowflake/version",
          :description => "Version of the spark-snowflake connector",
          :type => "string"

attribute "hadoop_spark/spark-snowflake/url",
          :description => "URL from where to download the spark-snowflake connector",
          :type => "string"
