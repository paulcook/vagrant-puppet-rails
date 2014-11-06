$rails_project = 'test-rails'
$db_names = ['test-rails_development','test-rails_test']

Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

class { 'puppi': }

# Update the system before starting with ruby etc
exec { 'apt-get update':
  command => 'apt-get update',
  timeout => 60,
  tries   => 3
}



package { ['python-software-properties']:
  ensure  => 'installed',
  require => Exec['apt-get update'],
}

$sysPackages = [ 'build-essential', 'git', 'vim', 'libxml2','libxml2-dev','libxslt1-dev','nodejs']

package { $sysPackages:
  ensure => "installed",
  require => Exec['apt-get update'],
}

user { 'vagrant':
  ensure => present,
}

# Install RVM and some gems then passenger/apache
class { 'rvm':
  version => '1.25.33',
}

rvm::system_user { vagrant: }

rvm_system_ruby {
  'ruby-2.1.4':
    ensure => present,
    require => Class['rvm::system'],
    default_use => true;
}

rvm_gem {
  'ruby-2.1.4/bundler':
    ensure => latest,
    require => Rvm_system_ruby['ruby-2.1.4'];
}

class {
  'rvm::passenger::apache':
    version => '3.0.12',
    ruby_version => 'ruby-2.1.4';
}

# Need to add step that sets up the apache vhost for this project for passenger

# Install Postgresql and setup databases
class install_postgres {

  class { 'postgresql': }
  class { 'postgresql::server': }

  pg_database { $db_names:
    ensure => present,
    encoding => 'UTF8',
    require => Class['postgresql::server'],
  }

  pg_user { "rails_user":
    ensure => present,
    require => Class['postgresql::server'],
    superuser => true,
  }

  package { 'libpq-dev':
    ensure => installed
  }

  package { 'postgresql-contrib':
    ensure  => installed,
    require => Class['postgresql::server'],
  }
}

class { 'install_postgres': }

class { 'apache_passenger_vhost':
  require => Class['rvm::passenger::apache'],
}