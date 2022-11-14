#puppet-yas3fs

[![Build Status](https://travis-ci.org/pcfens/puppet-yas3fs.png?branch=master)](https://travis-ci.org/pcfens/puppet-yas3fs)

####Table of Contents

1. [Overview](#overview)
2. [Module Description](#module-description)
3. [Setup - The basics of getting started with yas3fs](#setup)
    * [What yas3fs affects](#what-yas3fs-affects)
    * [Beginning with yas3fs](#beginning-with-yas3fs)
4. [Usage - Configuration options and additional functionality](#usage)
    * [Classes and Defined Types](#classes-and-defined-types)
        * [Class: yas3fs](#class-yas3fs)
        * [Defined Type: yas3fs::mount](#defined-type-yas3fs)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)

##Overview

The yas3fs module installs yas3fs, and provides a way to manage S3 mounts.

##Module Description

[yas3fs](https://github.com/danilop/yas3fs) is a python tool used to mount S3
buckets using fuse. yas3fs provides caching, as well as a mechanism for
invalidating caches on other nodes using SQS and SNS.

##Setup

###What yas3fs affects

* fuse package and configuration
* init jobs (sysvinit, upstart or systemd) that are used to manage yas3fs mounts
* python package

###Beginning with yas3fs

To install fuse and yas3fs from github source
```puppet
class { 'yas3fs':
}
```
##Usage

###Classes and Defined Types

####Class: `yas3fs`

The primary module. By default, fuse, and yas3fs are installed and
configured.

**Parameters within `yas3fs`**

#####`init_system`

Defines the type of init script/configuration to install out of `upstart`,
`systemd` or `sysvinit`. If the parameter is unset, autodiscovery takes place.
Default: $facts['service_provider']

#####`manage_python`

Defines if this module should attempt to install and manage python
Default: false

#####`manage_requirements`:

Defines if this module should attempt to install and manage yas3fs dependencies.
Default: true

#####`mounts`

A hash of mounts can be passed (possibly from hiera) as part of the class
declaration.

```puppet
class { 'yas3fs':
  mounts => {
    'example-mount' => {
      's3_url'     => 's3://example-bucket/',
      'local_path' => '/media/s3',
    }
  }
}
```
#####`python_version`:

Which version /usr/bin/pythonX[.Y] should be used to run yas3fs?
Major version X require, minor version Y is optional.
i.g. 3,3.6,3.8,2,2.7
Default: 3

#####`vcs_remote`

Optionally set yas3fs source code to be other than original
Default: 'https://github.com/danilop/yas3fs.git'

#####`vcs_revision`

Optionally set to use code from a specific commit or branch
Default: '5bbf8296b5cb16c8afecad94ea55d03c4052a683' # v2.4.6 No tag available 

#####`venv_path`

Path to python virtual environment. 
If set to '' system python library path will be used.
Highly recommend installing yas3fs to a virtual environment
to avoid causing issues with your python based package
management systems i.g. apt, yum...

####Defined Type: `yas3fs::mount`

Mounts a bucket/path using fuse by creating an init job.

```puppet
yas3fs::mount { 'example-mount':
  s3_url     => 's3://example-bucket/',
  local_path => '/media/s3',
  options    => [
    'recheck-s3',
    'uid 1000',
    'gid 1000',
  ]
}
```

**Parameters within `yas3fs::mount`**

#####`s3_url`

The S3 URL that should be mounted (e.g. s3://my-bucket/my-path)

#####`local_path`

The location where the S3 bucket should be mounted.

#####`ensure`

Control what to do with this mount. Valid values are `mounted` (default), `unmounted`, `absent`,
and `present`.

WARNING: setting ensure to `absent` removes the service configuration, but cannot
verify that the service is stopped.

#####`init_system`

Your init system so that proper mount startup script can be created.

#####`options`

An array of command line arguments that should be passed to yas3fs. The leading
dashes can be omitted. A full list of options is in the
[yas3fs documentation](https://github.com/danilop/yas3fs/blob/master/README.md).

#####`aws_access_key_id` and `aws_secret_access_key`

The credentials to use when connecting to AWS. Credentials can be omitted on EC2
instances with appropriate IAM roles assigned.

#####`venv_path`

The virtual environment where yas3fs is installed.
Help your init system start the mount properly. 

##Reference

###Classes

####Public Classes

* [`yas3fs`](#class-yas3fs): Guides the install of yas3fs

####Private Classes

* `yas3fs::config`: Manages the fuse configuration
* `yas3fs::install`: Installs fuse, and yas3fs
* `yas3fs::params`: Manages base parameters

###Defined Types

####Public Defined Types

* `yas3fs::mount`: Manages a single yas3fs mount

##Limitations

yas3fs is written for python 2.6, though there has been a lot of success running
it on 2.7, and now 3.x.
