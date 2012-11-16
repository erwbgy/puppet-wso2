class wso2esb::runtime (
  $config = undef
) {
  if $config {
    $defaults = {
      group   => $::wso2esb::group,
    }
    create_resources('wso2esb::user', $config, $defaults)
  }
}
