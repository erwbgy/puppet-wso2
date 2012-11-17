class wso2 (
  $config    = {},
  $user      = 'wso2',
  $group     = 'wso2',
  $basedir   = '/opt/wso2',
) {
  # TODO: Install patches in the correct order
  file { '/root/wso2':
    ensure  => directory,
  }
  exec { 'wso2-basedir':
    command => "/bin/mkdir -p ${basedir}",
    creates => $basedir,
  }
  Class['wso2'] -> Class['sunjdk']
  $products = hiera_hash('wso2::products', $config['products'])
  class { 'wso2::products':
    config => $products,
  }
  $runtime = hiera_hash('wso2::runtime', $config['runtime'])
  class { 'wso2::runtime':
    config => $runtime,
  }
  include '::wso2::config'
}
