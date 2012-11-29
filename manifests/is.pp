define wso2::is (
  $bind_address = $::fqdn,
  $db_name      = "wso2is-${title}",
  $db_username  = "wso2is-${title}",
  $db_password  = 'VRmcsa94w0VqUSVlMcBsDw',
  $db_vendor    = 'mysql',
  $jdbc_url     = "jdbc:mysql://localhost:3306/wso2is-${title}",
  $jdbc_driver  = 'com.mysql.jdbc.Driver',
  $extra_jars   = [],
  $group        = 'wso2',
  $home         = '/home',
  $java_home    = '/usr/java/latest',
  $java_opts    = '',
  $version      = undef,
  $slave        = false,
) {
  $user        = $title
  $product     = 'wso2is'
  $product_dir = "${home}/${user}/${product}-${version}"

  if ! defined(File["/etc/runit/${user}"]) {
    include runit
    runit::user { $user: group => $group }
  }

  wso2::install { "${user}-${product}":
    version     => "${product}-${version}",
    user        => $user,
    group       => $group,
    basedir     => "${home}/${user}",
  }

  $file_paths = prefix($extra_jars, "${product_dir}/")
  wso2::extra_jars { $file_paths:
    product_dir => $product_dir,
    destination => "${product_dir}/lib",
    user        => $user,
    require     => File[$product_dir],
  }

  wso2::user::service{ "${user}-${product}":
    product   => $product,
    user      => $user,
    group     => $group,
    version   => $version,
    java_home => $java_home,
    java_opts => $java_opts,
    home      => $home,
  }

  # Governance registry MySQL database
  # MySQL: http://mirrors.ibiblio.org/maven2/mysql/mysql-connector-java/

  case $db_vendor {
    undef: {
      # Use default H2 database
    }
    h2: {
      # Use default H2 database
    }
    mysql: {
      include mysql
      include mysql::server
      if ! defined (Database[$db_name]) {
        mysql::db { $db_name:
          user     => $db_username,
          password => $db_password,
          host     => 'localhost',
          grant    => ['all'],
        }
      }


      exec { "${db_name}-dbsetup":
        command     => "/usr/bin/mysql ${db_name} < $product_dir/dbscripts/mysql.sql",
        user        => $user,
        refreshonly => true,
        require     => Database[$db_name],
      }
    }
    default: {
      fail('currently only mysql is supported - please raise a bug on github')
    }
  }

  # Version 4.x
  if versioncmp($version, '4.0.0') > 0 {
    file { "${product_dir}/repository/conf/datasources/master-datasources.xml":
      ensure  => present,
      owner   => $user,
      group   => $group,
      mode    => '0400',
      content => template("wso2/${product}/4/master-datasources.xml.erb"),
      notify  => Exec["${db_name}-dbsetup"],
      require => File[$product_dir],
    }
    if $version == '4.0.0' {
      # Workaround for http://bugs.mysql.com/bug.php?id=4541
      # Should be fixed in 4.0.1 - https://wso2.org/jira/browse/IDENTITY-574
      file { "${product_dir}/dbscripts/identity/mysql.sql":
        ensure  => present,
        owner   => $user,
        group   => $group,
        mode    => '0400',
        content => template("wso2/${product}/4/identity-mysql.sql.erb"),
        notify  => Exec["${db_name}-dbsetup"],
        require => File[$product_dir],
      }
    }
  }
  # Version 3.2.x
  elsif versioncmp($version, '3.2.3') >= 0 {
    $embedded_ldap = true
    $external_ldap = false
    # carbon.xml
    file { "${product_dir}/repository/conf/carbon.xml":
      ensure  => present,
      owner   => $user,
      group   => $group,
      mode    => '0400',
      content => template("wso2/${product}/3/carbon.xml.erb"),
      require => File[$product_dir],
    }
    # registry.xml
    file { "${product_dir}/repository/conf/registry.xml":
      ensure  => present,
      owner   => $user,
      group   => $group,
      mode    => '0400',
      content => template("wso2/${product}/3/registry.xml.erb"),
      notify  => Exec["${db_name}-dbsetup"],
      require => File[$product_dir],
    }
    # cache.xml
    file { "${product_dir}/repository/conf/cache.xml":
      ensure  => present,
      owner   => $user,
      group   => $group,
      mode    => '0400',
      content => template("wso2/${product}/3/cache.xml.erb"),
      notify  => Exec["${db_name}-dbsetup"],
      require => File[$product_dir],
    }
    # user-mgt.xml
    file { "${product_dir}/repository/conf/user-mgt.xml":
      ensure  => present,
      owner   => $user,
      group   => $group,
      mode    => '0400',
      content => template("wso2/${product}/3/user-mgt.xml.erb"),
      notify  => Exec["${db_name}-dbsetup"],
      require => File[$product_dir],
    }
  }
  else {
    fail("version ${version} unsupported: currently only versions 3.2.3 and 4.0.x are supported")
  }
}
