define wso2::extra_jars (
  $product_dir,
  $destination,
  $user,
  $group = 'wso2',
  $home  = '/apps',
) {
  $jar_file = regsubst($title, "^${product_dir}/", '')
  file { "${destination}/${jar_file}":
    ensure  => present,
    owner   => $user,
    group   => $group,
    mode    => '0444',
    source  => "puppet:///files/wso2/${jar_file}",
    require => File[$product_dir],
  }
}
