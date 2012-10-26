class wso2esb::install (
  $version   = undef,
  $user      = undef,
  $group     = undef,
  $basedir   = undef,
  $workspace = undef
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
  if $workspace == undef {
    fail('wso2esb::install workspace paramter is required')
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
    path    => "${workspace}/${zipfile}",
    mode    => '0444',
    source  => "puppet:///files/${zipfile}",
    require => File[$workspace],
  }
  exec { 'wso2esb-unpack':
    cwd     => $basedir,
    command => "/usr/bin/unzip '${workspace}/${zipfile}'",
    creates => "${basedir}/${subdir}",
    notify  => Exec['wso2esb-fix-ownership'],
    require => [ Exec['wso2esb-basedir'], File['wso2esb-zipfile'] ],
  }
  exec { 'wso2esb-fix-ownership':
    command     => "/bin/chown -R ${user}:${group} ${basedir}/${subdir}",
    refreshonly => true,
  }
  file { "${basedir}/wso2esb":
    ensure  => link,
    target  => "${basedir}/${subdir}",
    require => Exec['wso2esb-basedir'],
  }
  # TODO: Add required config files from templates
  # TODO: Add JDBC database drivers -> ${wso2esb::basedir}/esb/lib/endorsed
}
