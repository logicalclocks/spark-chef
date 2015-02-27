actions :start_master, :start_slave

attribute :master_url, :kind_of => String, :name_attribute => true
attribute :slave_id, :kind_of => Integer, :default => 0

default_action :start_slave
