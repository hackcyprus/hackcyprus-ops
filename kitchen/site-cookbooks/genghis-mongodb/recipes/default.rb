include_recipe 'ruby'

execute 'install genghis' do
  command 'gem install genghisapp --no-rdoc --no-ri'
  action :run
end