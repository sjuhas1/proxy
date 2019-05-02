# == Class: puppet::server
#
# This class installs and manages the Puppet server daemon.
#
# === Parameters
#
# [*ensure*]
#   What state the package should be in. Defaults to +latest+. Valid values are
#   +present+ (also called +installed+), +absent+, +purged+, +held+, +latest+,
#   or a specific version number.
#
# [*package_name*]
#   The name of the package on the relevant distribution. Default is set by
#   Class['puppet::params'].
#
# === Actions
#
# - Install Puppet server package
# - Install puppet-lint gem
# - Configure Puppet to autosign puppet client certificate requests
# - Configure Puppet to use nodes.pp and modules from /vagrant directory
# - Ensure puppet-master daemon is running
#
# === Requires
#
# === Sample Usage
#
#   class { 'puppet::server': }
#
#   class { 'puppet::server':
#     ensure => 'puppet-2.7.17-1.el6',
#   }
#
class puppet::server(
  $ensure       = $puppet::params::server_ensure,
  $package_name = $puppet::params::server_package_name
) inherits puppet::params {

  # required to prevent syslog error on ubuntu
  # https://bugs.launchpad.net/ubuntu/+source/puppet/+bug/564861
  file { [ '/etc/puppet', '/etc/puppet/files', '/etc/puppet/code', '/etc/puppet/code/environments'  ]:
    ensure => directory,
    before => Package[ 'puppetmaster' ],
  }

  package { 'puppetmaster':
    ensure => $ensure,
    name   => $package_name,
  }

  package { 'puppet-lint':
    ensure   => latest,
    provider => gem,
  }
  
#  package { 'librarian-puppet':
#    ensure => latest,
#  }

  file { 'puppet.conf':
    path    => '/etc/puppet/puppet.conf',
    owner   => 'puppet',
    group   => 'puppet',
    mode    => '0644',
    source  => 'puppet:///modules/puppet/puppet.conf',
    require => Package[ 'puppetmaster' ],
    notify  => Service[ 'puppetmaster' ],
  }

  file { 'autosign.conf':
    path    => '/etc/puppet/autosign.conf',
    owner   => 'puppet',
    group   => 'puppet',
    mode    => '0644',
    content => '*',
    require => Package[ 'puppetmaster' ],
  }

  file { '/etc/puppet/code/environments/production':
    ensure  => link,
    target  => '/vagrant/production',
    require => Package[ 'puppetmaster' ],
    force => true,
  }


  file {  '/etc/puppet/hiera.yaml':
    ensure => link,
    target => '/vagrant/production/hiera.yaml',
    require => Exec[ 'module_puppet_nginx' ],
    force => true,
  }

  # initialize a template file then ignore
#  file { '/vagrant/nodes.pp':
#    ensure  => present,
#    replace => false,
#    source  => 'puppet:///modules/puppet/nodes.pp',
#  }

  service { 'puppetmaster':
    enable => true,
    ensure => running,
    notify => Exec[ 'module_puppet_stdlib' ],
  }
  
  exec { 'module_puppet_stdlib' :
    command     => '/usr/bin/puppet module install puppetlabs-stdlib --force',
    require     => Service[ 'puppetmaster' ],
    refreshonly => true,
    notify => Exec[ 'module_puppet_translate' ],
  }

  exec { 'module_puppet_translate' :
    command     => '/usr/bin/puppet module install puppetlabs-translate --force',
    require     => Exec[ 'module_puppet_stdlib' ],
    refreshonly => true,
    notify => Exec[ 'module_puppet_concat' ],
  }

  exec { 'module_puppet_concat' :
    command     => '/usr/bin/puppet module install puppetlabs-concat --force',
    require     => Exec[ 'module_puppet_translate' ],
    refreshonly => true,
    notify => Exec[ 'module_puppet_nginx' ],
  }

  exec { 'module_puppet_nginx' :
    command     => '/usr/bin/puppet module install puppet-nginx --force',
    require     => Exec[ 'module_puppet_concat' ],
    refreshonly => true,
  }

}
