
require 'spec_helper'

describe service('namenode') do  
  it { should be_enabled   }
  it { should be_running   }
end 

describe service('datanode') do  
  it { should be_enabled   }
  it { should be_running   }
end 

describe command("jps") do
  its (:stdout) { should match /Master/ }
  its (:stdout) { should match /Worker/ }
end

# describe service('JobHistoryServer') do  
#   it { should be_running   }
# end 

describe command("su hdfs -l -c \"/srv/hadoop/bin/hdfs dfs -ls /\"") do
  its (:stdout) { should match /mr-history/ }
end

describe command("su spark -l -c \"/srv/spark/bin/run-example SparkPi 10\"") do
  its (:stdout) { should match /Pi is roughly/ }
end


