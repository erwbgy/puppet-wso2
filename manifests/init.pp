class wso2esb (
  $version   = undef,
  $user      = 'wso2',
  $group     = 'wso2',
  $basedir   = '/opt/wso2',
  $workspace = '/root/wso2esb'
) {
  if $version == undef {
    fail('wso2 version parameter is required')
  }
  # TODO: Install patches in the correct order
  file { $workspace:
    ensure  => directory,
  }
  exec { 'wso2esb-basedir':
    command => "/bin/mkdir -p ${basedir}",
    creates => $basedir,
  }
  Class['wso2esb'] -> Class['sunjdk']
  class { 'wso2esb::install':
    version   => $version,
    user      => $user,
    group     => $group,
    basedir   => $basedir,
    workspace => $workspace,
  }
  class { 'wso2esb::config':
    group     => $group,
  }
}
