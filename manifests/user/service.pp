define wso2::user::service  (
  $basedir,
  $logdir,
  $product,
  $user,
  $group     = undef,
  $version   = undef,
  $java_home = '/usr/java/latest',
  $java_opts = '',
) {
  $installdir = "${basedir}/logscape-${version}"
  runit::service { "${product}-${user}":
    service     => $product,
    basedir     => $basedir,
    logdir      => $logdir,
    user        => $user,
    group       => $group,
    down        => true,
    timestamp   => false,
  }
  file { "${basedir}/runit/${product}/run":
    ensure  => present,
    mode    => '0555',
    owner   => $user,
    group   => $group,
    content => template("wso2/${product}/run.erb"),
    require => File["${basedir}/runit/${product}"],
  }
  file { "${basedir}/service/${product}":
    ensure  => link,
    target  => "${basedir}/runit/${product}",
    owner   => $user,
    group   => $group,
    replace => false,
    require => File["${basedir}/runit/${product}/run"],
  }
  file { "${logdir}/repository":
    ensure  => link,
    owner   => $user,
    target  => "${basedir}/product/${product}-${version}/repository/logs",
    require => File[$logdir],
  }
}
