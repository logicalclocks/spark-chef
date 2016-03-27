actions :start_master, :start_worker

attribute :master_url, :kind_of => String, :name_attribute => true
attribute :worker_id, :kind_of => Integer, :default => 0

default_action :start_worker
