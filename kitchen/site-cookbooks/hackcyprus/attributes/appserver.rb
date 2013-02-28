# ============================ #
# DEFAULT APPSERVER ATTRIBUTES #
# ============================ #

default[:appserver][:name] = "appserver"
default[:appserver][:home] = "/opt/appserver"
default[:appserver][:server] = "127.0.0.1:8000"
default[:appserver][:repo] = "git@github.com:hackcyprus/hacknest.git"