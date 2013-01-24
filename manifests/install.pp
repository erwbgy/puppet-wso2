define wso2::install (
  $version,
  $user,
  $group,
  $basedir,
) {
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
    source  => "puppet:///files/wso2/${zipfile}",
    require => File['/root/wso2'],
  }
  if ! defined(File["${basedir}/product"]) {
    file { "${basedir}/product":
      ensure => directory,
      mode   => '0750',
    }
  }
  exec { "wso2-unpack-${version}":
    cwd     => "${basedir}/product",
    command => "/usr/bin/unzip '/root/wso2/${zipfile}'",
    creates => "${basedir}/product/${subdir}",
    notify  => Exec["wso2-fix-ownership-${version}"],
    require => File["wso2-zipfile-${version}", "${basedir}/product"],
  }
  file { "${basedir}/product/${subdir}":
    ensure  => directory,
    require => Exec["wso2-unpack-${version}"],
  }
  exec { "wso2-fix-ownership-${version}":
    command     => "/bin/chown -R ${user}:${group} ${basedir}/product/${subdir}",
    refreshonly => true,
  }
}
