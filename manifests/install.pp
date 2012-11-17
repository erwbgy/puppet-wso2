define wso2::install (
  $user    = $::wso2::user,
  $group   = $::wso2::group,
  $basedir = $::wso2::basedir,
  $default = false
) {
  $version = $name
  $zipfile = "wso2-${version}.zip"
  $subdir  = "wso2-${version}"
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
  file { 'wso2-zipfile':
    ensure  => present,
    path    => "/root/wso2/${zipfile}",
    mode    => '0444',
    source  => "puppet:///files/${zipfile}",
    require => File['/root/wso2'],
  }
  exec { 'wso2-unpack':
    cwd     => $basedir,
    command => "/usr/bin/unzip '/root/wso2/${zipfile}'",
    creates => "${basedir}/${subdir}",
    notify  => Exec['wso2-fix-ownership'],
    require => [ Exec['wso2-basedir'], File['wso2-zipfile'] ],
  }
  file { "${basedir}/${subdir}":
    ensure  => directory,
    require => Exec['wso2-unpack']
  }
  exec { 'wso2-fix-ownership':
    command     => "/bin/chown -R ${user}:${group} ${basedir}/${subdir}",
    refreshonly => true,
  }
  if $default {
    file { "${basedir}/wso2":
      ensure  => link,
      target  => "${basedir}/${subdir}",
      require => Exec['wso2-basedir'],
    }
  }
  # TODO: Add required config files from templates
  # TODO: Add JDBC database drivers -> ${wso2::basedir}/esb/lib/endorsed
}
