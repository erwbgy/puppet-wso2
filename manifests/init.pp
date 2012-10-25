class wso2esb (
  $version = '4.5.0'
) {
  # TODO: Install patches in the correct order
  file { '/root/wso2esb':
    ensure  => directory,
  }
  $basedir = '/opt/wso2'
  $user    = 'wso2'
  $group   = 'wso2'
  file { $basedir:
    ensure  => directory,
    owner   => $user,
    group   => $group,
    require => User[$user]
  }
  Class['wso2esb'] -> Class['sunjdk']
  class { 'wso2esb::config':
    group   => $group,
  }
  class { 'wso2esb::install':
    version => $version,
    user    => $user,
    group   => $group,
    basedir => $basedir,
  }
}
