class wso2esb (
  $version = '4.5.0'
) {
  # TODO: Install patches in the correct order
  $workdir = '/var/lib/puppet/workspace/wso2esb'
  file { $workdir:
    ensure  => directory,
    require => File['/var/lib/puppet/workspace']
  }
  include user, iptables
  $basedir = '/opt/wso2'
  $user    = 'wso2'
  $group   = 'wso2'
  realize( User[$user] )
  file { $basedir:
    ensure  => directory,
    owner   => $user,
    group   => $group,
    require => User[$user]
  }
  Class['wso2esb'] -> Class['sunjdk']
  include wso2esb::config
  include wso2esb::install
}

define wso2esb::runtime () {
  $user = $title
  realize( User[$user] )
  file { "/home/${user}/service/wso2esb":
    ensure  => directory,
    mode    => '0755',
    owner   => $user,
    group   => $wso2esb::group,
    require => User[$user],
  }
  file { "/home/${user}/service/wso2esb/run":
    ensure  => present,
    mode    => '0555',
    owner   => $user,
    group   => $wso2esb::group,
    content => template('wso2esb/run.erb'),
    require => File["/home/${user}/service/wso2esb"],
  }
  file { "/home/${user}/service/wso2esb/log":
    ensure  => directory,
    mode    => '0755',
    owner   => $user,
    group   => $wso2esb::group,
    require => File["/home/${user}/service/wso2esb"],
  }
  file { "/home/${user}/service/wso2esb/log/run":
    ensure  => present,
    mode    => '0555',
    owner   => $user,
    group   => $wso2esb::group,
    content => template('wso2esb/log_run.erb'),
    require => File["/home/${user}/service/wso2esb/log"],
  }

  $basedir = $wso2esb::basedir
  $version = $wso2esb::version
  $subdir  = "wso2esb-${version}"
  exec { 'wso2esb-copy-product':
    cwd     => "/home/${user}",
    command => "/usr/bin/rsync -a '${basedir}/${subdir}' /home/${user}",
    require => Class['wso2esb::install'],
    creates => "/home/${user}/${subdir}",
    user    => $user,
    group   => $wso2esb::group,
    notify  => Exec['wso2esb-disable-scripts'],
  }
  exec { 'wso2esb-disable-scripts':
    cwd         => "/home/${user}/${subdir}/bin",
    command     => "/bin/sed -e '1aecho Run:' -e '1aecho \"  sv start|stop|status wso2esb\"' -e '1aecho instead' -e '1aexit 1' -i wso2server.sh wso2esb-samples.sh",
    user        => $user,
    group       => $wso2esb::group,
    refreshonly => true,
  }
  file { "/home/${user}/wso2esb":
    ensure  => link,
    target  => $subdir,
    owner   => $user,
    group   => $wso2esb::group,
    replace => false,
  }
  # TODO: Add required config files from templates
  # TODO: Add JDBC database drivers -> ${wso2esb::basedir}/esb/lib/endorsed
  runit::user{ $user: group => $wso2esb::group }
}
