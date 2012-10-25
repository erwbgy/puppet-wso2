class wso2esb::install (
  $version = undef,
  $user    = undef,
  $group   = undef,
  $basedir = undef
) {
  if $version == undef {
    fail('wso2esb::install version paramter is required')
  }
  if $user == undef {
    fail('wso2esb::install user paramter is required')
  }
  if $group == undef {
    fail('wso2esb::install group paramter is required')
  }
  if $basedir == undef {
    fail('wso2esb::install basedir paramter is required')
  }
  $zipfile = "wso2esb-${version}.zip"
  $subdir  = "wso2esb-${version}"
  package { ['jdk', 'unzip', 'rsync', 'sed']:
    ensure => installed,
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
    require => File[$wso2esb::basedir, 'wso2esb-zipfile'],
    creates => "${wso2esb::basedir}/${subdir}",
  }
  file { "${basedir}/wso2esb":
    ensure  => link,
    target  => "${basedir}/${subdir}",
    require => File[$wso2esb::basedir],
  }
  # TODO: Add required config files from templates
  # TODO: Add JDBC database drivers -> ${wso2esb::basedir}/esb/lib/endorsed
}
