
require 'spec_helper'

describe command("ps -ef | grep java | grep Master") do
  its(:exit_status) { should eq 0 }
end 


describe command("ps -ef | grep java | grep Worker") do
  its(:exit_status) { should eq 0 }
end 

describe command("su spark -l -c \"/srv/spark/bin/run-example SparkPi 10\"") do
  its (:stdout) { should match /Pi is roughly/ }
end

describe command("grep -Fxvf /home/spark/.ssh/id_rsa.pub /home/spark/.ssh/authorized_keys") do
  its(:exit_status) { should eq 0 }
end


