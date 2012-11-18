define wso2::user::service  (
  $user      = undef,
  $group     = undef,
  $version   = undef,
  $java_home = '/usr/java/latest',
  $java_opts = '',
  $home      = '/home'
) {
  if $version {
    $product = $title
    $subdir  = "${product}-${version}"
    exec { "wso2-copy-${product}-${user}":
      cwd     => "${home}/${user}",
      command => "/usr/bin/rsync -a '/opt/wso2/${subdir}' ${home}/${user}",
      require => File["${::wso2::basedir}/${subdir}"],
      creates => "${home}/${user}/${subdir}",
      user    => $user,
      group   => $group,
    }
    file { "${home}/${user}/${product}":
      ensure  => link,
      target  => $subdir,
      owner   => $user,
      group   => $group,
      replace => false,
      require => Exec["wso2-copy-${product}-${user}"],
    }
    runit::service { $product:
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

    # TODO: Add required config files from templates
    # TODO: Add JDBC database drivers -> $basedir/esb/lib/endorsed
  }
}
