class mongodb-arbiter {

 
package { [ "mongodb" ] :
}
 
service { "mongodb":
ensure => "running",
enable => "true",
require => Package["mongodb"]
}
 
file { "/etc/mongodb.conf":
notify => Service["mongodb"],
mode => 755,
owner => "mongodb",
group => "mongodb",
require => Package["mongodb"],
content => template("mongodb-server/mongodb.conf.erb")
}
}
