define wso2::user::service  (
  $product   = undef,
  $user      = undef,
  $group     = undef,
  $version   = undef,
  $java_home = '/usr/java/latest',
  $java_opts = '',
  $home      = '/home'
) {
  runit::service { "${user}-${product}":
    service     => $product,
    user        => $user,
    group       => $group,
  }
  file { "${home}/${user}/runit/${product}/run":
    ensure  => present,
    mode    => '0555',
    owner   => $user,
    group   => $group,
    content => template("wso2/${product}/run.erb"),
    require => File["${home}/${user}/runit/${product}"],
  }
  file { "${home}/${user}/service/${product}":
    ensure  => link,
    target  => "${home}/${user}/runit/${product}",
    owner   => $user,
    group   => $group,
    replace => false,
    require => File["${home}/${user}/runit/${product}/run"],
  }
  file { "${home}/${user}/logs/${product}/repository":
    ensure => link,
    owner  => $user,
    target => "${home}/${user}/${product}-${version}/repository/logs",
    force  => true,
  }
}
