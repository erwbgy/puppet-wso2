class wso2esb (
  $config    = {},
  $user      = 'wso2',
  $group     = 'wso2',
  $basedir   = '/opt/wso2',
) {
  # TODO: Install patches in the correct order
  file { '/root/wso2esb':
    ensure  => directory,
  }
  exec { 'wso2esb-basedir':
    command => "/bin/mkdir -p ${basedir}",
    creates => $basedir,
  }
  Class['wso2esb'] -> Class['sunjdk']
  $versions = hiera_hash('wso2esb::versions', $config['versions'])
  class { 'wso2esb::versions':
    config => $versions,
  }
  $runtime = hiera_hash('wso2esb::runtime', $config['runtime'])
  class { 'wso2esb::runtime':
    config => $runtime,
  }
  include '::wso2esb::config'
}
