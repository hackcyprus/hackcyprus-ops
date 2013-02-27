include_recipe 'apt'

apt_repository 'chef' do
    uri 'http://apt.opscode.com/'
    distribution node['lsb']['codename']
    components ['main']
    keyserver "keys.gnupg.net"
    key "83EF826A"
    action :add
end

package 'chef'