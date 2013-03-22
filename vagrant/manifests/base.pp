node default {
  include nginx
  include nodejs

  nginx::resource::upstream { 'my_cluster':
    ensure => present,
    members => [
      '192.168.33.10:3000',
      '192.168.33.11:3000'
    ]
  }

  nginx::resource::vhost { '192.168.33.10':
    ensure => present,
    proxy => 'http://my_cluster'
  }

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
      ensure => present;
    "mongodb":
      ensure => present;
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
    "/etc/mongodb.conf":
      owner => 'root',
      group => 'root',
      source => "puppet:///modules/express-sample/mongodb.conf",
      mode => 644,
      require => Package['mongodb'];
    "/etc/init.d/express-sample":
      owner => 'root',
      group => 'root',
      source => "puppet:///modules/express-sample/script.sh",
      mode => 755,
      require => Exec['config_app'];
  }

  service { 
    "express-sample":
      enable => true,
      ensure => running,
      pattern => '/home/appadmin/express-sample/app.js',
      require => [ File["/etc/init.d/express-sample"], Package['forever']];
    "mongodb":
      ensure => true,
      enable => true,
      subscribe => File["/etc/mongodb.conf"];
  }
}