define wso2esb::install (
  $user    = $::wso2esb::user,
  $group   = $::wso2esb::group,
  $basedir = $::wso2esb::basedir,
  $default = false
) {
  $version = $name
  $zipfile = "wso2esb-${version}.zip"
  $subdir  = "wso2esb-${version}"
  if ! defined(Package['unzip']) {
    package { 'unzip': ensure => installed }
  }
  if ! defined(Package['rsync']) {
    package { 'rsync': ensure => installed }
  }
  if ! defined(Package['sed']) {
    package { 'sed': ensure => installed }
  }
  # defaults
  File {
    owner => $user,
    group => $group,
  }
  file { 'wso2esb-zipfile':
    ensure  => present,
    path    => "/root/wso2esb/${zipfile}",
    mode    => '0444',
    source  => "puppet:///files/${zipfile}",
    require => File['/root/wso2esb'],
  }
  exec { 'wso2esb-unpack':
    cwd     => $basedir,
    command => "/usr/bin/unzip '/root/wso2esb/${zipfile}'",
    creates => "${basedir}/${subdir}",
    notify  => Exec['wso2esb-fix-ownership'],
    require => [ Exec['wso2esb-basedir'], File['wso2esb-zipfile'] ],
  }
  file { "${basedir}/${subdir}":
    ensure  => directory,
    require => Exec['wso2esb-unpack']
  }
  exec { 'wso2esb-fix-ownership':
    command     => "/bin/chown -R ${user}:${group} ${basedir}/${subdir}",
    refreshonly => true,
  }
  if $default {
    file { "${basedir}/wso2esb":
      ensure  => link,
      target  => "${basedir}/${subdir}",
      require => Exec['wso2esb-basedir'],
    }
  }
  # TODO: Add required config files from templates
  # TODO: Add JDBC database drivers -> ${wso2esb::basedir}/esb/lib/endorsed
}
