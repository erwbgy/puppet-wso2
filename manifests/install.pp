define wso2::install (
  $user    = $::wso2::user,
  $group   = $::wso2::group,
  $basedir = $::wso2::basedir,
  $default = false
) {
  $version = $name
  $zipfile = "${version}.zip"
  $subdir  = $version
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
  file { "wso2-zipfile-${version}":
    ensure  => present,
    path    => "/root/wso2/${zipfile}",
    mode    => '0444',
    source  => "puppet:///files/${zipfile}",
    require => File['/root/wso2'],
  }
  exec { "wso2-unpack-${version}":
    cwd     => $basedir,
    command => "/usr/bin/unzip '/root/wso2/${zipfile}'",
    creates => "${basedir}/${subdir}",
    notify  => Exec["wso2-fix-ownership-${version}"],
    require => [ Exec['wso2-basedir'], File["wso2-zipfile-${version}"] ],
  }
  file { "${basedir}/${subdir}":
    ensure  => directory,
    require => Exec["wso2-unpack-${version}"],
  }
  exec { "wso2-fix-ownership-${version}":
    command     => "/bin/chown -R ${user}:${group} ${basedir}/${subdir}",
    refreshonly => true,
  }
  #TODO if $default {
  #TODO   file { "${basedir}/wso2":
  #TODO     ensure  => link,
  #TODO     target  => "${basedir}/${subdir}",
  #TODO     require => Exec['wso2-basedir'],
  #TODO   }
  #TODO }
  # TODO: Add required config files from templates
  # TODO: Add JDBC database drivers -> ${wso2::basedir}/esb/lib/endorsed
}
