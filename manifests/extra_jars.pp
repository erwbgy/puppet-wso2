define wso2::extra_jars (
  $product_dir,
  $user,
  $home = '/home',
) {
  $jar_file = $title
  file { "${product_dir}/repository/components/lib/${jar_file}":
    ensure  => present,
    owner   => $user,
    group   => $group,
    mode    => '0444',
    source  => "puppet:///files/${jar_file}",
    require => File[$product_dir],
  }
}
