# -*- coding: utf-8 -*-
#
# Author:: Alex Michael
# Cookbook Name:: hackcyprus
# Recipe:: appserver
#
# Copyright 2012, Hack Cyprus
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Some strings..
#
export_environment = "export APPSERVER_ENV=#{node[:appserver][:environment]}"
cd_source_dir = "cd #{node[:appserver][:home]}"
export_app_secrets = "source /home/#{node[:appserver][:user]}/.appsecrets"

# Create the secrets variable hash
#
data_bags = ['hacknest', 'services']
secrets = {}
data_bags.each do |bag|
  data_bag(bag).each do |item|
    secrets[item] = data_bag_item(bag, item)
  end
end

['zip', 'daemon', 'curl', 'htop'].each do |pkg|
  package pkg do
    action :install
  end
end

user node[:appserver][:user] do
  gid "nogroup"
  home "/home/#{node[:appserver][:user]}"
  action :nothing
end.run_action(:create)

# Alex M:
# Not really sure about the security implications of these but it'll do
# for now. I'll come back to it later.
#
execute 'chown project root' do
  command "chown #{node[:appserver][:user]}:nogroup /opt"
  action :nothing
end.run_action(:run)

execute 'add read permissions for project root in development' do
  command 'sudo chmod a+r --recursive /opt/appserver'
  action :nothing
  only_if { node[:appserver][:environment] == 'development' }
end.run_action(:run)

ruby_block "enhance .profile" do
  block do
    file = Chef::Util::FileEdit.new("/home/#{node[:appserver][:user]}/.profile")
    [
      export_environment,
      cd_source_dir,
      export_app_secrets
    ].each do |line|
      file.insert_line_if_no_match(line, line)
      file.write_file
    end
  end
end

template "/home/#{node[:appserver][:user]}/.appsecrets" do
  source 'appserver.secrets'
  mode 0700
  owner node[:appserver][:user]
  group "nogroup"
  variables(secrets)
end

execute 'install nodemon globally for development' do
  command 'npm install nodemon -g'
  only_if { node[:appserver][:environment] == 'development' }
end

execute 'install grunt-cli globally' do
  command 'npm install grunt-cli -g'
end

execute 'install npm dependencies locally' do
  command 'npm install'
  user node[:appserver][:user]
  cwd "#{node[:appserver][:home]}"
end

python_pip "-r #{node[:appserver][:home]}/requirements.pip" do
  action :install
  only_if { File.exists?("#{node[:appserver][:home]}/requirements.pip") }
end

template "/etc/supervisor/conf.d/#{node[:appserver][:name]}.conf" do
  source 'appserver.supervisord.erb'
  owner node[:appserver][:user]
  group 'nogroup'
  mode 0644
  notifies :restart, 'service[supervisor]'
end

template "#{node[:nginx][:dir]}/sites-available/#{node[:appserver][:name]}" do
  source 'appserver.nginx.erb'
  owner 'www-data'
  group 'nogroup'
  mode 0644
end

nginx_site node[:appserver][:name] do
  enable true
end

nginx_site 'default' do
  enable false
end