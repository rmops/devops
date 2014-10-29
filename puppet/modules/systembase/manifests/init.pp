import "useradd.pp"
class systembase
{ 


user {'spree':
    ensure => 'present',
    home => '/home/spree',
    shell => '/bin/bash',
    managehome => 'true',
    groups => ['www-data', 'sudo', 'adm'],
   
  }

exec { "mkdir_ssh_dir":
    command => "ls /home/spree/.ssh||su spree -c 'mkdir /home/spree/.ssh'",
    path      => "/bin:/usr/local/sbin:/usr/bin:/usr/local/bin:/usr/local/sbin:/usr/sbin:/sbin",
    require => User[spree],
#    refreshonly => true,
    
  }

file { "/home/spree/.ssh/authorized_keys":
        mode => 0400,
        owner =>"spree",
        group =>"spree",
        require => User[spree],
        content => template("systembase/spree_authorized_keys.erb"),
      }

file { "/home/spree/.ssh/id_dsa":
        mode=>0400,
        content => template("systembase/spree_id_dsa.erb"),
        owner =>"spree",
        group =>"spree",
        require => File['/home/spree/.ssh/authorized_keys'],

        }

file { "/home/spree/.ssh/known_hosts":
        mode=>0644,
        source => "puppet:///modules/systembase/known_hosts",
        owner =>"spree",
        group =>"spree",
       require => File['/home/spree/.ssh/authorized_keys'],

        }

file { "/etc/environment":
    content => template("systembase/environment.erb"),
  }

#file { "/etc/hosts":
#        source => "puppet:///modules/systembase/hosts",
#        owner =>"root",
#        group =>"root",
#
#	}



package { openjdk-7-jdk:
    ensure =>"7~u3-2.1.1~pre1-1ubuntu2"
        }


file {
        "timezone":
        ensure => file,
        owner => root,
        group => root,
        mode  => 644,
        path => "/etc/timezone",
        source => "puppet:///modules/systembase/timezone",
        notify => Exec["up-timezone"],
                }




file { ntpfile:
    path=> "/usr/sbin/ntpdate",
    require =>Package['ntpdate'],
    }



exec {
        "up-timezone":
        command => "/usr/sbin/dpkg-reconfigure -f noninteractive tzdata",
        require => File["timezone"],
        subscribe=> File["timezone"],
        refreshonly => true,
                }
 
package { ntpdate:
                ensure => present,
         }
}
