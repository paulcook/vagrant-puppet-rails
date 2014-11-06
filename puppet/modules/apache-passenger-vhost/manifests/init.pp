class apache_passenger_vhost {

  # Remove the default vhost
  file { "/etc/apache2/sites-enabled/default.conf":
    ensure => absent,
  }

  $project_vhost = "/etc/apache2/sites-available/${rails_project}_default.conf"
  $default_vhost = template("apache-passenger-vhost/passenger-vhost.conf.erb")
  
  # Create the project vhost with default settings
  file { $project_vhost:
    ensure => present,
    content => $default_vhost,
  }

  # Enable the default conf
  file { "/etc/apache2/sites-enabled/${rails_project}_default.conf":
    ensure => link,
    target => $project_vhost,
  }
  
}
