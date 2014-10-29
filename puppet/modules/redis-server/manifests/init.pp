class redis-server
{

package {redis-server:
                #ensure => present,
		ensure => '2:2.2.12-1build1',
                }

file { "/etc/redis/redis.conf":
    content => template("redis-server/redis.conf.erb"),
    require => Package["redis-server"],
    notify => Service['redis-server'],

}

  service { "redis-server":
    ensure => "running",
    enable => true,
    require => [Package['redis-server'], File['/etc/redis/redis.conf'] ]
  }


}
