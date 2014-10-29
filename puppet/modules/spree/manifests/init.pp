define spree::app(){
  case $db_pass {
    "": { $db_pass = "spree"
      warning("db_pass not set, using default.")
    }
  }

  file {["/mnt/${name}","/mnt/${name}/shared/assets","/mnt/${name}/shared/script", "/mnt/${name}/releases", "/mnt/${name}/shared", "/mnt/${name}/shared/sockets", "/mnt/${name}/shared/config",
      "/mnt/${name}/shared/log", "/mnt/${name}/shared/pids", "/mnt/${name}/shared/tmp", "/mnt/${name}/shared/system"]:
    ensure => "directory", 
    owner => "spree", 
    group => "spree", 
    mode => 660, 
    require => [ File['/data'] ]
  }   

  file { "/mnt/${name}/shared/config/database.yml":
    content  => template("spree/database.yml.erb"),
    require => File["/mnt/${name}/shared/config"],
    owner => "spree", 
    group => "spree", 
    mode => 660 
  }

 file { "/mnt/${name}/shared/script/unicorn.sh":
    require => File["/mnt/${name}/shared/script"],
    content  => template("spree/unicorn.sh.erb"),
    owner => "spree",
    group => "spree",
    mode => 660
  }

 file { "/etc/rc.local":
    require => File["/mnt/${name}/shared/script"],
    content  => template("spree/rc.local.erb"),
    owner => "root",
    group => "root",
    mode => 0755,
  }


 file { "/mnt/${name}/shared/script/sidekiq.sh":
    require => File["/mnt/${name}/shared/script"],
    content  => template("spree/sidekiq.sh.erb"),
    owner => "spree",
    group => "spree",
    mode => 0755,
  }


  file { "/mnt/${name}/shared/config/redis.yml":
    content  => template("spree/redis.yml.erb"),
    require => File["/mnt/${name}/shared/config"],
    owner => "spree",
    group => "spree",
    mode => 660
  }




  file { "/mnt/${name}/shared/config/redis-cache.yml":
    content  => template("spree/redis-cache.yml.erb"),
    require => File["/mnt/${name}/shared/config"],
    owner => "spree",
    group => "spree",
    mode => 660
  }



file {"/mnt/${name}/shared/assets/manifest.*":
      ensure  => present,
      mode    => 660,
     owner => "spree",
    group => "spree",
     }

  file {"/mnt/${name}/shared/config/Procfile":
    content => template("spree/Procfile.erb"),
    require => File["/mnt/${name}/shared/config"],
    owner => "spree",
    group => "spree",
    mode => 660
  }

  file {"/mnt/${name}/shared/config/.foreman":
    content => template("spree/dot-foreman.erb"),
    require => File["/mnt/${name}/shared/config"],
    owner => "spree",
    group => "spree",
    mode => 660
  }

  file {"/mnt/${name}/shared/config/master.pill.erb":
    source  => "puppet:///modules/spree/bluepill_master.pill.erb",
    require => File["/mnt/${name}/shared/config"],
    owner => "spree",
    group => "spree",
    mode => 660
  }

  file {"/mnt/${name}/shared/config/${name}.pill":
    content => template("spree/placeholder.pill.erb"),
    require => File["/mnt/${name}/shared/config"],
    owner => "spree",
    group => "spree",
    mode => 660,
    replace => false
  }
}


# demo is only every defined for the 'spree' application
# so we don't refer to the $app_name variable
#
define spree::demo(){

  file { "/home/spree/demo_version":
    ensure  => 'present',
    content => inline_template("<%= spree_git_url %>"),
    require => User['spree']
  }

  exec { "checkout spree-demo":
    command => "rm -rf demo; git clone ${spree_git_url} demo",
    user    => 'spree',
    group   => 'spree',
    cwd     => "/mnt/${name}/releases",
    timeout => 500,
    logoutput => 'on_failure',
    subscribe => File['/home/spree/demo_version'],
    creates => '/mnt/${name}/releases/demo',
    require => [ Package['git-core'], User['spree'] ] 
  }

  file { "/mnt/${name}/current":
    ensure => "/mnt/${name}/releases/demo",
    require => [Exec['checkout spree-demo']]
  }   

  file { "/mnt/${name}/current/config/database.yml":
    ensure => "/mnt/${name}/shared/config/database.yml",
    owner => "spree", 
    group => "spree", 
    mode => 660,
    require => [Exec['checkout spree-demo']]
  }

  file { "/mnt/${name}/current/Procfile":
    ensure => "/mnt/${name}/shared/config/Procfile",
    require => [Exec['checkout spree-demo']]
  }   

  file { "/mnt/${name}/current/.foreman":
    ensure => "/mnt/${name}/shared/config/.foreman",
    require => [Exec['checkout spree-demo']]
  }   

  exec { "bundle install demo":
    command  => "bundle install --gemfile /mnt/${name}/releases/demo/Gemfile --path /mnt/${name}/shared/bundle --deployment --without development test",
    user      => 'spree',
    group     => 'spree',
    cwd       => "/mnt/${name}/releases/demo",
    logoutput => 'on_failure',
    timeout   => 3000,
    subscribe => Exec['checkout spree-demo'],
    refreshonly => true,
    require   => [Exec['checkout spree-demo'], File["/mnt/${name}/current/config/database.yml"] ]
  }

  # use subscribe here as pill gets created with a placeholder
  # by default to let bluepill start when we're not deploying a demo
  # so we can't use creates.

  exec { "foreman export demo":
    command => "bundle exec foreman export bluepill /mnt/${name}/shared/config",
    user => 'spree',
    group => 'spree',
    cwd => "/mnt/${name}/releases/demo",
    logoutput => true,
    timeout => 300,
    refreshonly => true,
    subscribe => File["/mnt/${name}/current/Procfile"],
    require => [ File["/mnt/${name}"], File["/mnt/${name}/current/.foreman"], File["/mnt/${name}/current/Procfile"], Exec["bundle install demo"] ]
  }

  exec { "restart bluepill":
    command => "bluepill load /mnt/${name}/shared/config/spree.pill",
    cwd => "/mnt/${name}/releases/demo",
    timeout => 300,
    logoutput => true,
    refreshonly => true,
    subscribe => Exec["foreman export demo"],
  }

  exec { "precompile assets for demo":
    command   => "bundle exec rake assets:precompile",
    user      => 'spree',
    group     => 'spree',
    cwd       => "/mnt/${name}/releases/demo",
    logoutput => 'true',
    timeout   => 1000,
    onlyif    => "/bin/sh -c 'bundle exec rake db:version --trace RAILS_ENV=${rails_env} | grep \"Current version: [0-9]\\{5,\\}\"'",
    creates   => "/mnt/${name}/releases/demo/public/assets",
    notify    => [Exec["restart bluepill"] ],
    require   => [ Exec["bundle install demo"], File["/mnt/${name}/current/config/database.yml"] ]
  }


}

