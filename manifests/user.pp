define wso2::user  (
  $version = undef,
  $group   = $::wso2::group,
  $home    = '/home'
) {
  $user = $name
  if $version == undef {
    fail('wso2::runtime version parameter required')
  }
  if $user == undef {
    fail('wso2::runtime user parameter required')
  }
  file { "${home}/${user}/service/wso2":
    ensure  => directory,
    mode    => '0755',
    owner   => $user,
    group   => $group,
  }
  file { "${home}/${user}/service/wso2/run":
    ensure  => present,
    mode    => '0555',
    owner   => $user,
    group   => $group,
    content => template('wso2/run.erb'),
    require => File["${home}/${user}/service/wso2"],
  }
  file { "${home}/${user}/service/wso2/log":
    ensure  => directory,
    mode    => '0755',
    owner   => $user,
    group   => $group,
    require => File["${home}/${user}/service/wso2"],
  }
  file { "${home}/${user}/service/wso2/log/run":
    ensure  => present,
    mode    => '0555',
    owner   => $user,
    group   => $group,
    content => template('wso2/log_run.erb'),
    require => File["${home}/${user}/service/wso2/log"],
  }

  $subdir  = "wso2-${version}"
  exec { "wso2-copy-product-${user}":
    cwd     => "${home}/${user}",
    command => "/usr/bin/rsync -a '/opt/wso2/${subdir}' ${home}/${user}",
    require => File["${::wso2::basedir}/${subdir}"],
    creates => "${home}/${user}/${subdir}",
    user    => $user,
    group   => $group,
    notify  => Exec["wso2-disable-scripts-${user}"],
  }
  exec { "wso2-disable-scripts-${user}":
    cwd         => "${home}/${user}/${subdir}/bin",
    command     => "/bin/sed -e '1aecho Run:' -e '1aecho \"  sv start|stop|status wso2\"' -e '1aecho instead' -e '1aexit 1' -i wso2server.sh wso2-samples.sh",
    user        => $user,
    group       => $group,
    refreshonly => true,
  }
  file { "${home}/${user}/wso2":
    ensure  => link,
    target  => $subdir,
    owner   => $user,
    group   => $group,
    replace => false,
  }
  # TODO: Add required config files from templates
  # TODO: Add JDBC database drivers -> $basedir/esb/lib/endorsed
  #runit::user{ $user: group => $group }
  #iptables::allow{ "wso2-http_wsdl-${user}":
  #  port     => '8280',
  #  protocol => 'tcp'
  #}
  #iptables::allow{ "wso2-https_wsdl-${user}":
  #  port     => '8243',
  #  protocol => 'tcp',
  #}
  #iptables::allow{ "wso2-console-${user}":
  #  port     => '9443',
  #  protocol => 'tcp'
  #}
}
