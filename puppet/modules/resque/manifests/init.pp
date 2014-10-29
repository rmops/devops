class resque
{

  package { "avahi-autoipd":
    ensure => "installed",
  }

 file { "/etc/init/resque.conf":
    content => template("resque/resque.conf.erb"),
    owner =>"avahi-autoipd",
    group =>"nogroup",
    require => Package[avahi-autoipd],
  }

 file { "/etc/init/resque-worker.conf":
    content => template("resque/resque-worker.conf.erb"),
    owner =>"avahi-autoipd",
    group =>"nogroup",
    require => Package[avahi-autoipd],
  }

}

