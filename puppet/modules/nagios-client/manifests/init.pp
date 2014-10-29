class nagios-client 
{

  package { "nagios3-core":
    ensure => "installed",
  }

package { "nagios-plugins":
    ensure => "installed",
  }


package { "nsca-client":
    ensure => "installed",
  }



 file { "/etc/nagios3/nagios.cfg":
    source  => "puppet:///modules/nagios-client/nagios.cfg",
    ensure => "present",
    owner =>"root",
    group =>"root",
    require => Package[nagios3-core],
  }

 file { "/etc/nagios3/commands.cfg":
    source  => "puppet:///modules/nagios-client/commands.cfg",
    ensure => "present",
    owner =>"root",
    group =>"root",
    require => Package[nagios3-core],
  }


file { "/etc/nagios3/resource.cfg":
    source  => "puppet:///modules/nagios-client/resource.cfg",
    ensure => "present",
    owner =>"root",
    group =>"root",
    require => Package[nagios3-core],
  }

file { "/usr/share/nagios3/plugins/eventhandlers/distributed-monitoring/submit_check_result_via_nsca":
    source  => "puppet:///modules/nagios-client/submit_check_result_via_nsca"),
    ensure => "present",
    owner =>"root",
    group =>"root",
    require => Package[nagios3-core],
  }


  file { "/etc/nagios3/conf.d/hostgroups_nagios2.cfg":
    owner =>"root",
    group =>"root",
    content => template("nagios-client/hostgroups_nagios2.cfg.erb"),
    notify => Service['nagios3']
  }


  file { "/etc/nagios3/conf.d/localhost_nagios2.cfg.erb"
    owner =>"root",
    group =>"root",
    content => template("nagios-client/localhost_nagios2.cfg.erb"),
    notify => Service['nagios3']
  }



}

