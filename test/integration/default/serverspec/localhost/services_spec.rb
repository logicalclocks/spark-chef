
require 'spec_helper'

# describe service('namenode') do  
#   it { should be_enabled   }
#   it { should be_running   }
# end 

# describe service('datanode') do  
#   it { should be_enabled   }
#   it { should be_running   }
# end 

describe service('Master') do  
  it { should be_running   }
end 

describe service('Worker') do  
  it { should be_running   }
end 

describe command("su spark -l -c \"/srv/spark/bin/run-example SparkPi 10\"") do
  its (:stdout) { should match /Pi is roughly/ }
end

describe command("grep -Fxvf /home/spark/.ssh/id_rsa.pub /home/spark/.ssh/authorized_keys") do
  its (:stdout) { should match // }
end


