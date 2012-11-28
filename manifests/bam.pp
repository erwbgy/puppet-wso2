class wso2::bam (
  $bind_address = $::fqdn,
  $db_name      = "wso2-${title}",
  $db_username  = 'wso2registry',
  $db_password  = 'VRmcsa94w0VqUSVlMcBsDw',
  $db_vendor    = 'mysql',
  $jdbc_url     = "jdbc:mysql://localhost:3306/wso2-${title}",
  $jdbc_driver  = 'com.mysql.jdbc.Driver',
  $extra_jars   = [],
  $group        = 'wso2',
  $home         = '/home',
  $java_home    = '/usr/java/latest',
  $java_opts    = '',
  $version      = undef,
) {
  $user        = $title
  $product_dir = "${home}/${user}/wso2bam-${version}"

  if ! defined(File["/etc/runit/${user}"]) {
    include runit
    runit::user { $user: group => $group }
  }

  wso2::install { "wso2bam-${version}":
    user        => $user,
    group       => $group,
    basedir     => "${home}/${user}",
  }

  wso2::extra_jars { $extra_jars:
    product_dir => $product_dir,
    user        => $user,
    require     => File[$product_dir],
  }

  wso2::user::service{ 'wso2bam':
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
      file { "${product_dir}/repository/conf/datasources/master-datasources.xml":
        ensure  => present,
        owner   => $user,
        group   => $group,
        mode    => '0400',
        content => template('wso2/wso2bam/master-datasources.xml.erb'),
        notify  => Exec["${db_name}-dbsetup"],
        require => File[$product_dir],
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
}
