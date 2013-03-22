node default {
  include nodejs

  user { "appadmin":
    comment => "App Admin",
    managehome => true,
    home => "/home/appadmin",
    ensure => present,
    shell => "/bin/bash",
    before => Package['nodejs']
  }

  package { 
    'g++':
      ensure => present,
      before => Package['forever'];
    'express':
      ensure   => present,
      provider => 'npm',
      require => Package['nodejs'];
    'forever':
      ensure   => present,
      provider => 'npm',
      require => Package['nodejs'];
    "git":
      ensure => present
  }

  exec { 
    "deploy_app":
      command => "/usr/bin/git clone https://github.com/mheimschild/express-sample.git /home/appadmin/express-sample",
      user => 'appadmin',
      creates => '/home/appadmin/express-sample',
      require => Package['git', 'nodejs', 'express'];
    "config_app":
      path => "/usr/bin:/usr/sbin:/bin:/usr/local/bin",
      cwd => "/home/appadmin/express-sample/",
      command => "/usr/bin/npm install",
      creates => "/home/appadmin/express-sample/node_modules",
      require => Exec['deploy_app']
  }

  file {
    "/etc/init.d/express-sample":
      owner => 'root',
      group => 'root',
      source => "puppet:///modules/express-sample/script.sh",
      mode => 755,
      require => Exec['config_app']
  }

  service { "express-sample":
    enable => true,
    ensure => running,
    require => [ File["/etc/init.d/express-sample"], Package['forever']],
  }
}