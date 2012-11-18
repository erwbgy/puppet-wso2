  #$products  = undef,
define wso2::user  (
  $group    = $::wso2::group,
  $home     = '/home',
  $wso2am   = {},
  $wso2abm  = {},
  $wso2esb  = {},
  $wso2greg = {}
) {
  $user = $title
  #file { '/tmp/l':
  #  ensure => present,
  #  content => $products,
  #}
  #debug( "products: '${products}'" )
  $defaults = {
    user  => $user,
    group => $group,
  }
  #create_resources('wso2::user::service', $products, $defaults)
  
  #create_resources('wso2::user::service', {}, $defaults)
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
    wso2::user::service{ 'wso2esb':
      user      => $user,
      group     => $group,
      version   => $wso2esb['version'],
      java_home => $wso2esb['java_home'],
      java_opts => $wso2esb['java_opts'],
      home      => $home,
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
