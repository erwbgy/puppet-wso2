# wso2esb1:
#    group: wso2
#    java_home: /usr/java/jdk1.7.0_07
#    version: 4.5.1

define wso2::esb (
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
  $product_dir = "${home}/${user}/wso2esb-${version}"

  if ! defined(File["/etc/runit/${user}"]) {
    runit::user { $user: group => $group }
  }

  wso2::install { "wso2esb-${version}":
    user        => $user,
    group       => $group,
    basedir     => $home,
  }

  $file_paths = prefix($extra_jars, "${product_dir}/")
  wso2::extra_jars { $file_paths:
    product_dir => $product_dir,
    user        => $user,
    require     => File[$product_dir],
  }

  wso2::user::service{ 'wso2esb':
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
        content => template('wso2/wso2esb/master-datasources.xml.erb'),
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

  # Config files
  file { "${product_dir}/repository/conf/axis2/axis2.xml":
    ensure  => present,
    owner   => $user,
    group   => $group,
    mode    => '0444',
    content => template('wso2/wso2esb/axis2.xml.erb'),
    require => File["${home}/${user}/wso2esb"],
  }
  file { "${product_dir}/repository/deployment/server/synapse-configs/default/sequences/main.xml":
    ensure  => present,
    owner   => $user,
    group   => $group,
    mode    => '0444',
    content => template('wso2/wso2esb/main.xml.erb'),
    require => File["${home}/${user}/wso2esb"],
  }
  file { "${product_dir}/repository/conf/etc/jmx.xml":
    ensure  => present,
    owner   => $user,
    group   => $group,
    mode    => '0444',
    content => template('wso2/wso2esb/jmx.xml.erb'),
    require => File["${home}/${user}/wso2esb"],
  }
  file { "${product_dir}/repository/conf/carbon.xml":
    ensure  => present,
    owner   => $user,
    group   => $group,
    mode    => '0444',
    content => template('wso2/wso2esb/carbon.xml.erb'),
    require => File["${home}/${user}/wso2esb"],
  }
}
