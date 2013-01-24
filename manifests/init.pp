class wso2 {
  include '::wso2::config'

  file { '/root/wso2':
    ensure => directory,
    owner  => 'root',
    group  => 'wso2',
    mode   => '0750',
  }

#  # API Manager
#  $am = hiera_hash('wso2::am', undef)
#  if $am {
#    create_resources('wso2::am', $am)
#  }
#
#  # Business Actvity Monitor
#  $bam = hiera_hash('wso2::bam', undef)
#  if $bam {
#    create_resources('wso2::bam', $bam)
#  }

  # Enterprise Service Bus
  $esb = hiera_hash('wso2::esb', undef)
  if $esb {
    create_resources('wso2::esb', $esb)
  }

#  # Governance Registry
#  $greg = hiera_hash('wso2::greg', undef)
#  if $greg {
#    create_resources('wso2::greg', $greg)
#  }
#
#  # Identity Server
#  $is = hiera_hash('wso2::is', undef)
#  if $is {
#    create_resources('wso2::is', $is)
#  }
}
