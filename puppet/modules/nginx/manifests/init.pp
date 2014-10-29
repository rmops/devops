class nginx {

#install nginx package from puppet master server
  exec { "add-apt-repository nginx":
    command => "dpkg -i /var/cache/apt/archives/nginx_1.2.7+precise_amd64.deb",
    alias => "nginx_repository",
    require => Package["libxml2","libxslt1.1","libxslt1-dev","libgd2-xpm","libgd2-xpm-dev","libgeoip1","libgeoip-dev","libssl-dev","libpcre3","libpcre3-dev","libssl0.9.8","libjemalloc-dev"],
    refreshonly => true,
    path      => "/bin:/usr/local/sbin:/usr/bin:/usr/local/bin:/usr/local/sbin:/usr/sbin:/sbin",
    subscribe => File["/var/cache/apt/archives/nginx_1.2.7+precise_amd64.deb"],
  }

#push nginx package to client
  file { "/var/cache/apt/archives/nginx_1.2.7+precise_amd64.deb":
      owner =>"root",
      group =>"root", 
      ensure => "present",
      source  => "puppet:///modules/nginx/nginx_1.2.7+precise_amd64.deb"
	}


#http auth to protect some url
file { "/etc/nginx/authfile":
      owner =>"root",
      group =>"root", 
      ensure => "present",
      source  => "puppet:///modules/nginx/authfile",
        }

#https ssl key
  file { "/etc/nginx/${app_name}.key":
      owner =>"root",
      group =>"root", 
      ensure => "present",
      source  => "puppet:///modules/nginx/${app_name}.key"
        }

#default 403 page
  file { "/etc/nginx/html/403.html":
      owner =>"root",
      group =>"root", 
      ensure => "present",
      source  => "puppet:///modules/nginx/403.html",
        }

#https ssl cert
  file { "/etc/nginx/${app_name}.crt":
      owner =>"root",
      group =>"root", 
      ensure => "present",
      source  => "puppet:///modules/nginx/${app_name}.crt"
        }

#https ssl  cert for both-way check ca
  file { "/etc/nginx/${app_name}.client.ca.crt":
      owner =>"root",
      group =>"root", 
      ensure => "present",
      source  => "puppet:///modules/nginx/${app_name}.client.ca.crt"

        }

#ssl client crl  verification  both-way check
  file { "/etc/nginx/${app_name}.client.ca.crl":
      owner =>"root",
      group =>"root", 
      ensure => "present",
      source  => "puppet:///modules/nginx/${app_name}.client.ca.crl"
        }


#nginx required package list
$package_list = [ "libgd2-xpm","libgd2-xpm-dev","libgeoip1","libgeoip-dev","libxslt1.1","libpcre3","libpcre3-dev","libssl0.9.8","libjemalloc-dev" ] 
package { $package_list: 
    ensure => "installed" 
}
  
#check nginx installed or not
package { "nginx":
    ensure => "present",
    require => [ Exec['add-apt-repository nginx'] ]
  }

#check nginx service status
  service { "nginx":
    ensure => "running",
    enable => true,
    require => [Package['nginx'], File['/etc/nginx/nginx.conf'] ]
  }

#update nginx.conf from puppet master,and if update it will notify to restart nginx service
  file { "/etc/nginx/nginx.conf":
      owner =>"root",
      group =>"root", 
    content => ["/mnt/${app_name}/config/nginx/nginx.conf", template("nginx/nginx.conf.erb")],
    require => Package['nginx'],
    notify => Service['nginx']
  }


  file {"/etc/nginx/sites-enabled/default":
      owner =>"root",
      group =>"root", 
    ensure => "absent",
    notify => Service['nginx']
  }
}

#update app nginx config from puppet master,and if update it will notify to restart nginx service
define nginx::site {

  file { "/etc/nginx/sites-available/${name}":
    content => template("nginx/sites-available/site.erb"),
    require => [ Package['nginx'] ],
#    replace => false,
    notify => Service['nginx']
  }

  file { "/etc/nginx/sites-enabled/${name}":
      owner =>"root",
      group =>"root", 
    ensure => "/etc/nginx/sites-available/${name}",
    require => File["/etc/nginx/sites-available/${name}"],
    notify => Service['nginx']
  }

  file { "/etc/nginx/sites-available/${name}-secure":
      owner =>"root",
      group =>"root", 
    content => template("nginx/sites-available/secure.erb"),
    require => [ Package['nginx'] ],
 #  replace => false,
    notify => Service['nginx']
  }

#use a soft link from sites-available to sites-enable  
 exec { "ln -nfs /etc/nginx/sites-available/${name}-secure /etc/nginx/sites-enabled/${name}-secure":
    require => File["/etc/nginx/sites-available/${name}-secure"],
    unless => "ls /etc/nginx/sites-enabled/${name}-secure 2>/dev/null",

    notify => Service['nginx']
  }


#add nginx logrote
 file { "/etc/logrotate.d/nginx":
      owner =>"root",
      group =>"root", 
    content => template("nginx/logrotate.nginx.erb"),
  }

#add unicorn logrote
file { "/etc/logrotate.d/unicorn":
      owner =>"root",
      group =>"root", 
    content => template("nginx/logrotate.unicorn.erb"),
  }


}
