require 'spec_helper'

describe service('datanode') do
  it { should be_enabled   }
  it { should be_running   }
end

describe service('nodemanager') do
  it { should be_enabled   }
  it { should be_running   }
end

describe service('mysqld') do  
  it { should be_enabled   }
  it { should be_running   }
end 

describe service('namenode') do
  it { should be_enabled   }
  it { should be_running   }
end

describe service('resourcemanager') do
  it { should be_enabled   }
  it { should be_running   }
end

describe command("/var/lib/mysql-cluster/ndb/scripts/mysql-client.sh -e \"show databases\"") do
  its (:stdout) { should match /mysql/ }
end

describe command("su hdfs -l -c \"echo 'test data' > /tmp/hopsie\"") do
  its(:exit_status) { should eq 0 }
end

describe command("su hdfs -l -c \"/srv/hadoop/bin/hdfs dfs -rm -f /hops\"") do
  its(:exit_status) { should eq 0 }
end

describe command("su hdfs -l -c \"/srv/hadoop/bin/hdfs dfs -copyFromLocal /tmp/hopsie /hops\"") do
  its(:exit_status) { should eq 0 }
end

describe command("su hdfs -l -c \"/srv/hadoop/bin/hdfs dfs -ls /\"") do
  its (:stdout) { should match /hops/ }
end

describe command("su yarn -l -c \"/srv/hadoop/bin/yarn jar /srv/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.4.0.jar pi 1 1000 \"") do
  its (:stdout) { should match /Estimated value of Pi is/ }
end

describe command("service datanode restart") do
  its(:exit_status) { should eq 0 }
end

describe command("service resourcemanager restart") do
  its(:exit_status) { should eq 0 }
end

describe command("service nodemanager restart") do
  its(:exit_status) { should eq 0 }
end

describe service('sparkhistoryserver') do
  it { should be_enabled   }
  it { should be_running   }
end

describe command("service sparkhistoryserver restart") do
  its(:exit_status) { should eq 0 }
end


describe command("su spark -l -c \"HADOOP_CONF_DIR=/srv/hadoop/etc/hadoop /srv/spark/bin/spark-submit --verbose --class org.apache.spark.examples.SparkPi --master yarn --deploy-mode client --driver-memory 512m --executor-memory 512m --queue default --num-executors 1 /srv/spark/examples/jars/spark-examples_2.11-2.0.1.jar 100\"") do
  its (:stdout) { should match /Pi is roughly/ }
end

describe command("su spark -l -c \"HADOOP_CONF_DIR=/srv/hadoop/etc/hadoop /srv/spark/bin/spark-submit --verbose --class org.apache.spark.examples.SparkPi --master yarn --deploy-mode cluster --driver-memory 512m --executor-memory 512m --queue default --num-executors 1 /srv/spark/examples/jars/spark-examples_2.11-2.0.1.jar 100\"") do
  its(:exit_status) { should eq 0 }
end
