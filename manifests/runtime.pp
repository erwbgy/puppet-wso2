class wso2::runtime (
  $config = undef
) {
  if $config {
    $defaults = {
      group   => $::wso2::group,
    }
    create_resources('wso2::user', $config, $defaults)
  }
}
