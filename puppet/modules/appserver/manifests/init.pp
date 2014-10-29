class appserver {
  include nginx

  nginx::site{$app_name:}
  appserver::unicorn{$app_name:}
}

define appserver::unicorn(){
  file {"/mnt/${name}/shared/config/unicorn.rb":
    content => template("appserver/unicorn.rb.erb"),
    require => File["/mnt/${name}/shared/config"],
    owner => "spree",
    group => "www-data",
    mode => 660
  }
}
