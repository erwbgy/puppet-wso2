class wso2 {
  include '::wso2::config'

  # API Manager
  $am = hiera_hash('wso2::am', {})
  if $am {
    create_resources('::wso2::am', $am)
  }

  # Business Actvity Monitor
  $bam = hiera_hash('wso2::bam', {})
  if $bam {
    create_resources('::wso2::bam', $bam)
  }

  # Enterprise Service Bus
  $esb = hiera_hash('wso2::esb', {})
  if $esb {
    create_resources('::wso2::esb', $esb)
  }

  # Governance Registry
  $greg = hiera_hash('wso2::greg', {})
  if $greg {
    create_resources('::wso2::greg', $greg)
  }

  # Identity Server
  $is = hiera_hash('wso2::is', {})
  if $is {
    create_resources('::wso2::is', $is)
  }
}
