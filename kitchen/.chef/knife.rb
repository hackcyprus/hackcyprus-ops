current_dir = File.dirname(__FILE__)
log_level                :info
log_location             STDOUT
node_name                "hackcyprus"
client_key               "#{current_dir}/hackcyprus.pem"
validation_client_name   "hackcyprus-validator"
validation_key           "#{current_dir}/hackcyprus-validator.pem"
chef_server_url          "https://api.opscode.com/organizations/hackcyprus"
cache_type               'BasicFile'
cache_options( :path => "#{ENV['HOME']}/.chef/checksums" )
cookbook_path            ["#{current_dir}/../cookbooks"]
