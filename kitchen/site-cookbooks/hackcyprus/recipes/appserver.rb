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
puts node[:appserver][:user]

['zip', 'daemon', 'curl', 'htop'].each do |pkg|
  package pkg do
    action :install
  end
end

execute 'enhance .bashrc for development' do
  command <<-EOS
    echo 'export APPSERVER_ENV=#{node[:appserver][:environment]}' >> .bashrc
    echo 'cd #{node[:appserver][:home]}' >> .bashrc
  EOS
  cwd '~'
  only_if { node[:appserver][:environment] == 'development' }
end

execute 'install nodemon for development' do
    command 'npm install nodemon -g'
    only_if { node[:appserver][:environment] == 'development' }
end

template '/etc/supervisor/conf.d/#{node[:appserver][:name]}.conf' do
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