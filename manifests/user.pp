  #$products  = undef,
define wso2::user  (
  $group    = $::wso2::group,
  $home     = '/home',
  $wso2am   = {},
  $wso2bam  = {},
  $wso2esb  = {},
  $wso2greg = {}
) {
  $user = $title
  $defaults = {
    user  => $user,
    group => $group,
  }
  # If not run: table 'UM_DIALECT' doesn't exist
  #  mysql greg-wso2esb1 < /home/wso2esb1/wso2esb-4.5.1/dbscripts/mysql.sql
  if $wso2am {
    wso2::user::service{ 'wso2am':
      user      => $user,
      group     => $group,
      version   => $wso2am['version'],
      java_home => $wso2am['java_home'],
      java_opts => $wso2am['java_opts'],
      home      => $home,
    }  
  }
  if $wso2bam {
    wso2::user::service{ 'wso2bam':
      user      => $user,
      group     => $group,
      version   => $wso2bam['version'],
      java_home => $wso2bam['java_home'],
      java_opts => $wso2bam['java_opts'],
      home      => $home,
    }  
  }
  if $wso2esb {
    $db_name      = "wso2-${user}"
    $db_username  = 'wso2registry'
    $db_password  = 'VRmcsa94w0VqUSVlMcBsDw'
    $jdbc_url     = "jdbc:mysql://localhost:3306/${db_name}"
    $jdbc_driver  = 'com.mysql.jdbc.Driver'
    $version      = $wso2esb['version']
    $java_home    = $wso2esb['java_home']
    $java_opts    = $wso2esb['java_opts']
    $product_dir  = "${home}/${user}/wso2esb-${version}"
    $bind_address = $::fqdn
    wso2::user::service{ 'wso2esb':
      user      => $user,
      group     => $group,
      version   => $version,
      java_home => $java_home,
      java_opts => $java_opts,
      home      => $home,
    }
    mysql::db { $db_name:
      user     => $db_username,
      password => $db_password,
      host     => 'localhost',
      grant    => ['all'],
    }
    file { "${product_dir}/repository/conf/datasources/master-datasources.xml":
      ensure  => present,
      owner   => $user,
      group   => $group,
      mode    => '0400',
      content => template('wso2/wso2esb/master-datasources.xml.erb'),
      notify  => Exec["${db_name}-dbsetup"],
      require => File["${home}/${user}/wso2esb"],
    }
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
    exec { "${db_name}-dbsetup":
      command     => "/usr/bin/mysql ${db_name} < $product_dir/dbscripts/mysql.sql",
      user        => $user,
      refreshonly => true,
      require     => Database[$db_name],
    }
    file { "${product_dir}/repository/components/lib/WSDL_Mediator-2.0.0.jar":
      ensure  => present,
      owner   => $user,
      group   => $group,
      mode    => '0444',
      source  => "puppet:///files/WSDL_Mediator-2.0.0.jar",
      require => File["${home}/${user}/wso2esb"],
    }
    file { "${product_dir}/repository/components/lib/coherence-3.7.1.6.jar":
      ensure  => present,
      owner   => $user,
      group   => $group,
      mode    => '0444',
      source  => "puppet:///files/coherence-3.7.1.6.jar",
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
  if $wso2greg {
    wso2::user::service{ 'wso2greg':
      user      => $user,
      group     => $group,
      version   => $wso2greg['version'],
      java_home => $wso2greg['java_home'],
      java_opts => $wso2greg['java_opts'],
      home      => $home,
    }  
  }
}
