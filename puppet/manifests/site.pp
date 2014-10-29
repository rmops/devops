import "nodes.pp"
Exec { path => [ "/usr/local/bin", "/usr/bin/", "/usr/sbin/", "/bin", "/sbin" ] }
#$rails_env = 'development'
$ruby_version = '1.9.3-p125'
$unicorn_workers = 3
$loadbalancer = false
$db_server = '127.0.0.1'
$app_name = 'spree'
$mysql_password = '123456'
$mysql_user = "spree"
$db_pass='puma'
$spree_git_url='https://github.com/spree/spree.git'
