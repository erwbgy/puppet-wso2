class wso2esb::versions (
  $config = undef
) {
  if $config {
    $defaults = {
      user    => $::wso2esb::user,
      group   => $::wso2esb::group,
      basedir => $::wso2esb::basedir,
    }
    create_resources('wso2esb::install', $config, $defaults)
  }
}
