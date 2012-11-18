define wso2::user  (
  $product = undef,
  $group   = $::wso2::group,
  $home    = '/home'
) {
  $user = $title
  runit::service { $product:
    user        => $user,
    group       => $group,
  }
  ##file { "${home}/${user}/service/wso2/run":
  ##  ensure  => present,
  ##  mode    => '0555',
  ##  owner   => $user,
  ##  group   => $group,
  ##  content => template('wso2/run.erb'),
  ##  require => File["${home}/${user}/service/wso2"],
  ##}

  $subdir  = $product
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
  ##file { "${home}/${user}/wso2":
  ##  ensure  => link,
  ##  target  => $subdir,
  ##  owner   => $user,
  ##  group   => $group,
  ##  replace => false,
  ##}
  # TODO: Add required config files from templates
  # TODO: Add JDBC database drivers -> $basedir/esb/lib/endorsed
}
