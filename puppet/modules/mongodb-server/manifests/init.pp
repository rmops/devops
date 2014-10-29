class mongodb-server {

exec { "add-10gen-key":
command => "apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10",
unless => "apt-key list | grep 10gen",
path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"
}

exec { "10gen-repo" :
command => "echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen'|tee -a /etc/apt/sources.list",
require => Exec["add-10gen-key"],
unless => "grep 10gen /etc/apt/sources.list",
path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"
}


exec { "mongodb-apt-ready" :
command => "/usr/bin/apt-get update",
require => Exec["10gen-repo"],
unless => "/usr/bin/test  -x /usr/bin/mongo",
path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"
}

package { [ "mongodb-10gen" ] :
ensure => "2.4.3",
require => Exec["mongodb-apt-ready"]
}

exec { "mongodb-data-move" :
command => "cp -ar /var/lib/mongodb /mnt/&&chown -R mongodb:nogroup /mnt/mongodb && rm -rf /var/lib/mongodb",
require => Package["mongodb-10gen"],
unless => "[ ! -d /var/lib/mongodb ]",
path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"
}
 
service { "mongodb":
ensure => "running",
enable => "true",
require => Exec["mongodb-data-move"]
}

 
file { "/etc/mongodb.conf":
notify => Service["mongodb"],
mode => 755,
owner => "mongodb",
group => "mongodb",
require => Package["mongodb-10gen"],
content => template("mongodb-server/mongodb.conf.erb")
}
}
