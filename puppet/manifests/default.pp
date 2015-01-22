$rails_project = 'buckeye_vault'
$db_names = ['buckeye_vault_development','buckeye_vault_test']

Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

include stdlib

# Update the system before starting with ruby etc
class { 'apt':
  always_apt_update => true,
}

package { ['python-software-properties']:
  ensure  => 'installed',
  require => Class['apt'],
}

$sysPackages = [ 'build-essential', 'git', 'vim', 'libxml2','libxml2-dev','libxslt1-dev','nodejs']

package { $sysPackages:
  ensure => "installed",
  require => Class['apt'],
}

class { 'apache':
  require => Class['apt'],
}

user { 'vagrant':
  ensure => present,
}

 # Install RVM and some gems then passenger/apache
class { 'rvm':
  require => Class['apache'],
}

rvm::system_user { vagrant: }

rvm_system_ruby {
  'ruby-2.1.5':
    ensure => present,
    require => Class['rvm::system'],
    default_use => true;
}

rvm_gem {
  'ruby-2.1.4/bundler':
    ensure => latest,
    require => Rvm_system_ruby['ruby-2.1.5'];
}

class {
  'rvm::passenger::apache':
    ruby_version => 'ruby-2.1.5';
}

# class { 'apache_passenger_vhost':
#   require => Class['install_rvm_passenger'],
# }

# # Install Postgresql and setup databases
class install_postgres {

  class { 'postgresql::server': }

  postgresql::server::db { $db_names:
    user => 'rails',
    password => 'tempPass4u'
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

# exec {
#   'bundle rails':
#     command => 'bundle',
#     cwd => "/vagrant/${rails_project}",
#     user => 'vagrant',
#     environment => ["HOME=/home/vagrant"],
# }

