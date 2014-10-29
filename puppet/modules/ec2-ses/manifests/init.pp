class ec2-ses
{

file {"postfix-main.cf":
        path=>"/etc/postfix/main.cf",
        content => template("ec2-ses/main.cf.erb"),        
        owner=>"root",
        group=>"root",
        mode=>644,
#        source =>"puppet:///modules/ec2-ses/main.cf",
        require =>Package['postfix'],
        }

file {"sender_canonical":
        path=>"/etc/postfix/sender_canonical",
        owner=>"root",
        group=>"root",
        mode=>644,
        content => template("ec2-ses/sender_canonical.erb"),        
        require =>Package['postfix'],
        }

file {"postfix-key":
        path=>"/etc/postfix/sasl_passwd.db",
        owner=>"root",
        group=>"root",
        mode=>644,
        source =>"puppet:///modules/ec2-ses/sasl_passwd.db",
        require =>Package['postfix'],
        }



package {postfix:
                ensure => present,
                }
exec {
        "postfix-reload":
        command => "/etc/init.d/postfix restart",
        path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
        subscribe => [File["postfix-main.cf"],File["postfix-key"]],
        refreshonly => true,
        timeout=>0,
        }


}

