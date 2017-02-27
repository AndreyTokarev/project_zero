Exec { path => [ '/bin', '/sbin', '/usr/bin', '/usr/sbin', ] }

exec { 'system-update':
  	command => '/usr/bin/apt-get update'
}
Exec['system-update'] -> Package <| |>

Package { ensure => "installed" }

package { 'zip': }
package { 'unzip': }
package { 'wget': }
package { 'curl': }
package { 'apache2': }
package { 'mysql-server': }
package { 'php5': }
package { 'libapache2-mod-php5': }
package { 'php5-mysql': }
package { 'php5-mcrypt': }
package { 'mysql-client': }
package { 'phpmyadmin': }
package { "libapache2-mod-auth-mysql": }

exec { "mysqlpasswd":
        command => "/usr/bin/mysqladmin -u root password Dt94ahsr",
        notify => [Service["mysql"], Service["apache2"]],
        require => [Package["mysql-server"], Package["apache2"]],
}

# ensure apache2 service is running
service { 'apache2':
  	  ensure => running,
  	  enable => "true",
  	  require => Package['apache2'],
}

# ensure mysql service is running
service { 'mysql':
  	  ensure => running,
  	  enable => "true",
  	  require => Package['mysql-server'],
}

file { '/etc/apache2/sites-available/phpmyadmin.conf':
  ensure => link,
  target => '/etc/phpmyadmin/apache.conf',
  require => Package['phpmyadmin'],
}

exec { 'enable-phpmyadmin':
  command => 'sudo a2ensite phpmyadmin.conf',
  require => File['/etc/apache2/sites-available/phpmyadmin.conf'],
}

#file { '/etc/apache2/sites-available/site.conf':
#  ensure => link,
#  target => '/vagrant/conf/apache2/site.conf',
#  require => Package['apache2'],
#}
#
#exec { 'enable-site.conf':
#  command => 'sudo a2ensite site.conf',
#  require => File['/etc/apache2/sites-available/site.conf'],
#}
#
#exec { 'disable-default.conf':
#  command => 'sudo a2dissite 000-default.conf',
#  require => Exec['enable-site.conf'],
#}

#exec { 'restart-apache':
#  command => 'sudo /etc/init.d/apache2 restart',
#  require => [Exec['enable-phpmyadmin'], Exec['enable-site.conf']],
#}

file { '/var/www/html':
   ensure => link,
   target => '/vagrant/www',
   force => true,
   require => Package['apache2'],
}

# ensure info.php file exists
file { '/var/www/html/info.php':
  ensure => file,
  content => '<?php  phpinfo(); ?>',    # phpinfo code
  require => File['/var/www/html'],        # require 'apache2' package before creating
}


exec { 'restart-apache':
  command => 'sudo /etc/init.d/apache2 restart',
  require => [Exec['enable-phpmyadmin'], File['/var/www/html']],
}
