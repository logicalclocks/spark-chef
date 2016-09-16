# Apache Spark Chef cookbook

### Install Spark standalone

### Install Spark yarn


## References

 * https://documentation.altiscale.com/spark-2-0-with-altiscale
 * https://www.linkedin.com/pulse/running-spark-2xx-cloudera-hadoop-distro-cdh-deenar-toraskar-cfa
 * 



 set "spark.yarn.jars"
$ Cd  $SPARK_HOME
$ hadoop fs mkdir spark-2.0.0-bin-hadoop 
$hadoop fs -copyFromLocal jars/* spark-2.0.0-bin-hadoop 
$ echo "spark.yarn.jars=hdfs:///nameservice1/user/<yourusername>/spark-2.0.0-bin-hadoop/*" >> conf/spark-defaults.conf


If you do have access to the local directories of all the nodes in your cluster you can copy the archive or spark jars to the local directory of each of the data nodes using rsync or scp. Just update the URLs from hdfs:/ to local:



