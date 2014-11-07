$rails_project = 'test-rails'
$db_names = ['test-rails_development','test-rails_test']

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
  mpm_module => 'worker',
  require => Class['apt'],
}

user { 'vagrant':
  ensure => present,
}

# Exec { environment => ["rvmsudo_secure_path=1"] }

 # Install RVM and some gems then passenger/apache
class { 'rvm':
  version => '1.25.33',
  require => Class['apache'],
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
    version => '4.0.53',
    ruby_version => 'ruby-2.1.4';
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

