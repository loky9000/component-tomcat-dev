tomcat-dev
==========

![](http://tomcat.apache.org/images/tomcat-power.gif)

Installs and configures Apache Tomcat 6.

[![Install](https://raw.github.com/qubell-bazaar/component-skeleton/master/img/install.png)](https://express.qubell.com/applications/upload?metadataUrl=https://raw.github.com/qubell-bazaar/component-tomcat-dev/master/meta.yml)

Features
--------

 - Install and configure Tomcat in parallel on multiple compute
 - Deploy and update code in parallel (WAR file to a chosen context, all servers at once)
 - Scale out and back in
 - Stop and restart Tomcat services

Configurations
--------------
[![Build Status](https://travis-ci.org/qubell-bazaar/component-tomcat-dev.png?branch=master)](https://travis-ci.org/qubell-bazaar/component-tomcat-dev)

 - Tomcat 6.x (latest), CentOS 6.3 (us-east-1/ami-eb6b0182), AWS EC2 m1.small, root
 - Tomcat 6.x (latest), CentOS 5.3 (us-east-1/ami-beda31d7), AWS EC2 m1.small, root
 - Tomcat 6.x (latest), Ubuntu 12.04 (us-east-1/ami-d0f89fb9), AWS EC2 m1.small, root
 - Tomcat 6.x (latest), Ubuntu 10.04 (us-east-1/ami-0fac7566), AWS EC2 m1.small, root

Pre-requisites
--------------
 - Configured Cloud Account a in chosen environment
 - Either installed Chef on target compute OR launch under root
 - Internet access from target compute:
  - Tomcat distibution: TBD (RPM for CentOS, Deb for Ubuntu)
  - S3 bucket with Chef recipes: (TBD)
  - If Chef is not installed: (TBD)

Implementation notes
--------------------
 - Installation is based on Chef recipes from http://community.opscode.com/cookbooks/tomcat

Example usage
-------------
TBD
