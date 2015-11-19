# _Unmaintained_

I no longer use Puppet actively and this software has not been maintained for some time.

# puppet-wso2

Puppet module to install WSO2 products and set them up to run as Runit services
under one or more users.

The recommended usage is to place the configuration is hiera and just:

    include wso2

Example hiera config:

    # Enterprise Service Bus
    wso2::esb:
      wso2esb1:
        extra_jars:
          - coherence-3.7.1.6.jar
          - mysql-connector-java-5.1.21.jar
          - WSDL_Mediator-2.0.0.jar
        group: wso2
        java_home: /usr/java/jdk1.7.0_07
        version: 4.5.1
      wso2esb2:
        extra_jars:
          - mysql-connector-java-5.1.21.jar
        java_home: /usr/java/jdk1.6.0_37
        version: 4.5.0
    
    # Identity Server
    wso2::is:
      wso2is1:
        extra_jars:
          - mysql-connector-java-5.1.21.jar
        group: wso2
        java_home: /usr/java/jdk1.7.0_07
        version: 4.0.0
    
    # Governance Registry
    wso2::greg:
      wso2greg1:
        extra_jars:
          - mysql-connector-java-5.1.21.jar
        version: 4.5.2
    
    # API Manager
    wso2::am:
      wso2am1:
        extra_jars:
          - mysql-connector-java-5.1.21.jar
        version: 1.2.0
    
    # Business Activity Monitor
    wso2::bam:
      wso2bam1:
        extra_jars:
          - mysql-connector-java-5.1.21.jar
        version: 2.0.1

## Parameters

All product classes take following parameters:

*title*: The user the product runs as

*bind_address*: The IP address listen sockets are bound to. Default: $::fqdn

*db_name*: Database name. Default: "wso2-${title}",

*db_username*: Database username. Default: 'wso2registry',

*db_password*: Database user password. Default: 'VR...Dw',

*db_vendor*: The database vendor. Possible values: 'undef' or 'h2' for default H2 database; 'mysql'. Default: 'mysql',

*jdbc_url*: Default: "jdbc:mysql://localhost:3306/wso2-${title}",

*jdbc_driver*: Default: 'com.mysql.jdbc.Driver',

*extra_jars*: Additional jar files to be placed in the repository/component/lib directory

*group*: The user's primary group. Default: 'wso2',

*home*: The parent directory of user home directories Default: '/home',

*java_home*: The base directory of the JDK installation to be used. Default: '/usr/java/latest',

*java_opts*: Additional java command-line options to pass to the startup script

*version*: The version of the product to install (eg. 4.5.1). **Required**.

## Product zip files

Place the product zip files (eg. wso2esb-4.5.1.zip) under the 'files' file store.  For example if /etc/puppet/fileserver.conf has:

    [files]
    path /var/lib/puppet/files

the put the zip files in /var/lib/puppet/files.

## Notes

Currently:

* Only the ESB and Identity Server have been tested

* Some of the changes are specific to my setup and may not be application to yours

* Only MySQL database support is present but I plan to add Postgres and Oracle support

## Support

License: Apache License, Version 2.0

GitHub URL: https://github.com/erwbgy/puppet-wso2
