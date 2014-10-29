class nagios-server 
{

  package { "nagios3-core":
    ensure => "installed",
  }

package { "nagios-plugins":
    ensure => "installed",
  }



package { "nsca":
    ensure => "installed",
  }




 file { "/etc/nagios3/nagios.cfg":
    source  => "puppet:///modules/nagios-server/nagios.cfg",
    ensure => "present",
    owner =>"root",
    group =>"root",
    require => Package[nagios3-core],
  }

 file { "/etc/nagios3/commands.cfg":
    source  => "puppet:///modules/nagios-server/commands.cfg",
    ensure => "present",
    owner =>"root",
    group =>"root",
    require => Package[nagios3-core],
  }


file { "/etc/nagios3/resource.cfg":
    source  => "puppet:///modules/nagios-server/resource.cfg",
    ensure => "present",
    owner =>"root",
    group =>"root",
    require => Package[nagios3-core],
  }


  file { "/etc/nagios3/conf.d/hostgroups_nagios2.cfg":
    source  => "puppet:///modules/nagios-server/hostgroups_nagios2.cfg",
    owner =>"root",
    group =>"root",
    notify => Service['nagios3']
  }


  file { "/etc/nagios3/conf.d/prod_hosts.cfg":
    owner =>"root",
    group =>"root",
    source  => "puppet:///modules/nagios-server/prod_hosts.cfg",
    notify => Service['nagios3']
  }

 file { "/etc/nagios3/conf.d/contacts_nagios2.cfg":
    source  => "puppet:///modules/nagios-server/contacts_nagios2.cfg",
    ensure => "present",
    owner =>"root",
    group =>"root",
    require => Package[nagios3-core],
  }


 file { "/etc/nagios3/conf.d/services_nagios2.cfg":
    source  => "puppet:///modules/nagios-server/services_nagios2.cfg",
    ensure => "present",
    owner =>"root",
    group =>"root",
    require => Package[nagios3-core],
  }


 file { "/etc/nagios-plugins/config/http.cfg":
    source  => "puppet:///modules/nagios-server/http.cfg",
    ensure => "present",
    owner =>"root",
    group =>"root",
    require => Package[nagios3-core],
  }

  
 file { "/etc/nagios-plugins/config/tcp_udp.cfg":
    source  => "puppet:///modules/nagios-server/tcp_udp.cfg",
    ensure => "present",
    owner =>"root",
    group =>"root",
    require => Package[nagios3-core],
  }


 file { "/etc/nagios-plugins/config/telnet.cfg":
    source  => "puppet:///modules/nagios-server/telnet.cfg",
    ensure => "present",
    owner =>"root",
    group =>"root",
    require => Package[nagios3-core],
  }



 file { "/etc/nagios-plugins/config/check_nrpe.cfg":
    source  => "puppet:///modules/nagios-server/check_nrpe.cfg",
    ensure => "present",
    owner =>"root",
    group =>"root",
    require => Package[nagios3-core],
  }



 file { "/etc/nsca.cfg":
    source  => "puppet:///modules/nagios-server/nsca.cfg",
    ensure => "present",
    owner =>"root",
    group =>"root",
    require => Package[nsca],
  }

 service { "nagios3":
    ensure => "running",
    enable => true,
    require => Package['nagios3-core'], 
  }


}


