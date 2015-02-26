actions :start_master, :start_slave

attribute :master_url, :kind_of => String, :name_attribute => true

default_action :start_slave
