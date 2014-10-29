class newrelic{
  exec { 
    "add-apt-repository newrelic":
    command => "wget -O /etc/apt/sources.list.d/newrelic.list http://download.newrelic.com/debian/newrelic.list &&
		apt-key adv --keyserver hkp://subkeys.pgp.net --recv-keys 548C16BF &&
		apt-get update",
    alias => "newrelic_repository",
    unless => "ls /etc/apt/sources.list.d/newrelic.list 2>/dev/null",
  }
  
  $package_list = [ "newrelic-sysmond" ] 

  package { $package_list: 
    ensure => "installed",
     require => Exec['newrelic_repository']
  }

  service { "newrelic-sysmond":
    ensure => "running",
    enable => true,
    require => [Package['newrelic-sysmond'],Exec['add-newlic-license-key']]
  }

  exec {
    "add-newlic-license-key":
    command => "nrsysmond-config --set license_key=3ee260f7c6bfa",
    alias => "newrelic_license_key",
    require => Package['newrelic-sysmond'], 
    unless => "grep 3303ee260f7c6bfa /etc/newrelic/nrsysmond.cfg 2>/dev/null",
  }     

  file { "/etc/newrelic/newrelic_mysql_plugin-1.0.2.jar":
#      require => [ Package['newrelic'] ],
      ensure => "present",
      source  => "puppet:///modules/newrelic/newrelic_mysql_plugin-1.0.2.jar",
      owner =>"root",
      group =>"root",

  }
}
