class wso2::versions (
  $config = undef
) {
  if $config {
    $defaults = {
      user    => $::wso2::user,
      group   => $::wso2::group,
      basedir => $::wso2::basedir,
    }
    create_resources('wso2::install', $config, $defaults)
  }
}
