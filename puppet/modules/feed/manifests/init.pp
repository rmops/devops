class feed
{

 file { "feed_conf":
    path=>"/etc/init/feed.conf",
    content => template("feed/feed.conf.erb"),
  }

package {"npm":
                ensure => present,
		require => File["feed_conf"],

               }


exec { "start_feed" :
command => "start feed",
require => Package["npm"],
unless => "ps aux |grep node |grep -v grep",
path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"
}

}

