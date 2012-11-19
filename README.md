# puppet-wso2esb

Puppet module to install WSO2 products and set them up to run as Runit services
under one or more users.

The recommended usage is to place the configuration is hiera and just:

    include wso2

Example hiera config:

    # WSO2 product installs
    wso2::products:
      # Specify all the defaults explicitly
      wso2esb-4.5.0:
        user:    wso2
        group:   wso2
        basedir: /opt/wso2
      # Specify all the defaults explicitly, but with a different user
      wso2esb-4.5.1:
        user:    wso2esb
        group:   wso2
        basedir: /opt/wso2
      # Use a different basedir, with defaults for the rest
      wso2greg-4.5.2:
        basedir: /usr/local/wso2
      # Use the defaults for everything
      wso2am-1.2.0: {}
    
    # Users running WSO2 products under Runit
    wso2::runtime:
      wso2esb1:
        group: wso2
        wso2esb:
          java_home: /usr/java/jdk1.6.0_37
          version: 4.5.1
        # Uses JAVA_HOME set to /usr/java/latest
        wso2greg:
          version: 4.5.2
     wso2run2:
       wso2am:
          version: 1.2.0

## wso2::products

Installs WSO2 products.

*title*: The product name and version (eg. wso2esb-4.5.1)

*user*: The owner of the installed files. Default: wso2

*group*: The group of the installed files. Default: wso2

*basedir*: The base directory under which the product will be installed. Default: /opt/wso2

## wso2::runtime

Sets up one or more WSO2 products to run as Runit services under the specified user accounts.

For each user listed under wso2::runtime:

*title*: The username of the user running the products (eg. wso2esb1)

*group*: The group of installed files. Default: wso2

For each product listed under each user:

*title*: The product name - one of: wso2am, wso2bam, wso2esb, wso2greg

*version*: The version of the product to install

*java_home*: The base directory of the JDK installation to be used. Default: /usr/java/latest

*java_opts*: The java command-line options to pass to the startup script

## Support

License: Apache License, Version 2.0

GitHub URL: https://github.com/erwbgy/puppet-wso2
