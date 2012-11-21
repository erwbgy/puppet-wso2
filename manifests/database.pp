class wso2::database (
  $vendor      = 'mysql',
  $jdbc_driver = undef,
) {
  # TODO: Fix hiera lookup of class parameters
  case $vendor {
    mysql: {
      include mysql
      include mysql::server
    }
    default: {
      fail('currently only mysql is supported - please raise a bug on github')
    }
  }
}
