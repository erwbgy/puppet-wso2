class wso2esb::config (
  $group = 'wso2'
) {
  # From http://wso2.org/project/esb/java/4.0.0/docs/admin_guide.html
  augeas { 'wso2esb-sysctl':
    context => '/files/etc/sysctl.conf',
    changes => [
      'set net.ipv4.tcp_fin_timeout 30',
      'set fs.file-max 2097152',
      'set net.ipv4.tcp_tw_recycle 1',
      'set net.ipv4.tcp_tw_reuse 1',
      'set net.core.rmem_default 524288',
      'set net.core.wmem_default 524288',
      'set net.core.rmem_max 67108864',
      'set net.core.wmem_max 67108864',
      'set net.ipv4.tcp_rmem 4096 87380 16777216',
      'set net.ipv4.tcp_wmem 4096 65536 16777216',
    ],
  }
  include limits
  limits::conf { 'wso2esb-soft':
    domain => "@${group}",
    type   => 'soft',
    item   => 'nofile',
    value  => '4096'
  }
  limits::conf { 'wso2esb-hard':
    domain => "@${group}",
    type   => 'hard',
    item   => 'nofile',
    value  => '65535'
  }
  iptables::allow{ 'wso2esb-http_wsdl':  port => '8280', protocol => 'tcp' }
  iptables::allow{ 'wso2esb-https_wsdl': port => '8243', protocol => 'tcp' }
  iptables::allow{ 'wso2esb-console':    port => '9443', protocol => 'tcp' }
}
