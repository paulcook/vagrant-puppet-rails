class apache_passenger_vhost {
  exec {
    'disable default site':
      command => 'a2dissite 15-default',
  }
  file {
    '/etc/apache2/sites-available/default.conf':
      ensure => present,
      content => template('apache_passenger_vhost/rails_project.conf.erb'),
  }
  exec {
    'enable new default site':
      command => 'a2ensite default',
      require => Class['apache']
  }
}