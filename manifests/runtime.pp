define wso2esb::runtime  (
  $version = undef,
  $user    = undef,
  $group   = undef,
  $home    = '/home'
) {
  if $version == undef {
    fail('wso2esb::runtime version parameter required')
  }
  if $user == undef {
    fail('wso2esb::runtime user parameter required')
  }
  if $group == undef {
    fail('wso2esb::runtime group parameter required')
  }
  file { "${home}/${user}/service/wso2esb":
    ensure  => directory,
    mode    => '0755',
    owner   => $user,
    group   => $group,
  }
  file { "${home}/${user}/service/wso2esb/run":
    ensure  => present,
    mode    => '0555',
    owner   => $user,
    group   => $group,
    content => template('wso2esb/run.erb'),
    require => File["${home}/${user}/service/wso2esb"],
  }
  file { "${home}/${user}/service/wso2esb/log":
    ensure  => directory,
    mode    => '0755',
    owner   => $user,
    group   => $group,
    require => File["${home}/${user}/service/wso2esb"],
  }
  file { "${home}/${user}/service/wso2esb/log/run":
    ensure  => present,
    mode    => '0555',
    owner   => $user,
    group   => $group,
    content => template('wso2esb/log_run.erb'),
    require => File["${home}/${user}/service/wso2esb/log"],
  }

  $subdir  = "wso2esb-${version}"
  exec { 'wso2esb-copy-product':
    cwd     => "${home}/${user}",
    command => "/usr/bin/rsync -a '/opt/wso2/${subdir}' ${home}/${user}",
    require => Class['wso2esb::install'],
    creates => "${home}/${user}/${subdir}",
    user    => $user,
    group   => $group,
    notify  => Exec['wso2esb-disable-scripts'],
  }
  exec { 'wso2esb-disable-scripts':
    cwd         => "${home}/${user}/${subdir}/bin",
    command     => "/bin/sed -e '1aecho Run:' -e '1aecho \"  sv start|stop|status wso2esb\"' -e '1aecho instead' -e '1aexit 1' -i wso2server.sh wso2esb-samples.sh",
    user        => $user,
    group       => $group,
    refreshonly => true,
  }
  file { "${home}/${user}/wso2esb":
    ensure  => link,
    target  => $subdir,
    owner   => $user,
    group   => $group,
    replace => false,
  }
  # TODO: Add required config files from templates
  # TODO: Add JDBC database drivers -> $basedir/esb/lib/endorsed
  runit::user{ $user: group => $group }
  iptables::allow{ "wso2esb-http_wsdl-${user}":
    port     => '8280',
    protocol => 'tcp'
  }
  iptables::allow{ "wso2esb-https_wsdl-${user}":
    port     => '8243',
    protocol => 'tcp',
  }
  iptables::allow{ "wso2esb-console-${user}":
    port     => '9443',
    protocol => 'tcp'
  }
}
