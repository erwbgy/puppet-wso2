class wso2esb::install {
  $workdir = $wso2esb::workdir
  $version = $wso2esb::version
  $zipfile = "wso2esb-${version}.zip"
  $subdir  = "wso2esb-${version}"
  realize( Package['jdk', 'unzip', 'rsync', 'sed'] )
  realize( User[$wso2esb::user] )
  # defaults
  File {
    owner => $wso2esb::user,
    group => $wso2esb::group,
  }
  file { 'wso2esb-zipfile':
    ensure  => present,
    path    => "${workdir}/${zipfile}",
    mode    => '0444',
    source  => "puppet:///files/${zipfile}",
    require => File[$workdir],
  }
  exec { 'wso2esb-unpack':
    cwd     => $wso2esb::basedir,
    command => "/usr/bin/unzip '${workdir}/${zipfile}'",
    require => File[$wso2esb::basedir, 'wso2esb-zipfile'],
    creates => "${wso2esb::basedir}/${subdir}",
  }
  file { "${wso2esb::basedir}/wso2esb":
    ensure  => link,
    target  => "${wso2esb::basedir}/${subdir}",
    require => File[$wso2esb::basedir],
  }
  # TODO: Add required config files from templates
  # TODO: Add JDBC database drivers -> ${wso2esb::basedir}/esb/lib/endorsed
}
