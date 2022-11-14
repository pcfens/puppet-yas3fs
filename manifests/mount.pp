# A yas3fs mount
# Defined type to create one or more mount points
# to S3 bucket endpoints
#
# * `s3_url`:
#   Full S3 url path
#   i.g. s3://my-bucket/my-path/
#
# * `local_path`
#   The path on the system that S3 bucket
#   contents should be mount
#   i.g. /mnt/bucket_here
#
# * `ensure`
#   Define the state of the S3 mount
#   Validate options:
#   mounted,unmounted,present,absent
#
# * `options`
#   Array of command line options to passed
#   to yas3fs at mount time. 
#   Full list of options available at 
#   https://github.com/danilop/yas3fs/blob/master/README.md#full-usage
#
# * `aws_access_key_id`
#   Access key id of IAM user with IAM policies
#   granting access to the S3 bucket defined in s3_url
#
# * `aws_access_access_key`
#   Secret access key of Access key id defined above
#   Omitting Access key id and Secret access key will
#   let yas3fs rely on IAM Profile of EC2 instance. 
#
# * `venv_path`
#   The virtual environment where yas3fs is installed.
#   Help your init system start the mount properly. 
#
define yas3fs::mount (
  String[6] $s3_url,
  String[1] $local_path,
  Enum['mounted','unmounted','present','absent'] $ensure = 'mounted',
  Enum['systemd','sysvinit','upstart'] $init_system      = $::yas3fs::init_system,
  Array $options                                         = [],
  Optional[String] $aws_access_key_id                    = undef,
  Optional[String] $aws_secret_access_key                = undef,
  String $venv_path                                      = $::yas3fs::venv_path,
) {
  validate_array($options)
  validate_string($s3_url, $local_path, $aws_access_key_id, $aws_secret_access_key)

  include ::yas3fs

  file { $local_path:
    ensure => directory,
  }

  case $ensure {
    'mounted': {
      $init_file_ensure = 'present'
      $service_ensure = 'running'
      $service_enable = true
    }
    'unmounted': {
      $init_file_ensure = 'present'
      $service_ensure = 'stopped'
      $service_enable = false
    }
    'present': {
      $init_file_ensure = 'present'
      $service_ensure = 'running'
      $service_enable = true
    }
    'absent': {
      $init_file_ensure = 'absent'
    }
    default: {
      fail('Only mounted, unmounted, and present are valid ensure values for yas3fs::mount')
    }
  }

  case $init_system {
    'systemd': {
      exec { "yas3fs_reload_systemd-${name}":
        # SystemD needs a reload after any unit file change
        command     => 'systemctl daemon-reload',
        # Thank @djtaylor https://github.com/pcfens/puppet-yas3fs/pull/5
        # /usr/bin/env yas3fs
        path        => ['/bin', '/sbin', '/usr/bin', '/usr/sbin', '/usr/local/bin'],
        refreshonly => true,
        subscribe   => File["yas3fs-${name}"],
        before      => Service["s3fs-${name}"],
      }
      file { "yas3fs-${name}":
        ensure  => $init_file_ensure,
        path    => "/etc/systemd/system/s3fs-${name}.service",
        content => template('yas3fs/systemd.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0600',
        notify  => Service["s3fs-${name}"],
      }
    }
    'upstart': {
      file { "yas3fs-${name}":
        ensure  => $init_file_ensure,
        path    => "/etc/init/s3fs-${name}.conf",
        content => template('yas3fs/upstart.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0600',
        notify  => Service["s3fs-${name}"],
      }
    }
    'sysvinit': {
      file { "yas3fs-${name}":
        ensure  => $init_file_ensure,
        path    => "/etc/init.d/s3fs-${name}",
        content => template('yas3fs/sysvinit.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0700',
        notify  => Service["s3fs-${name}"],
      }
    }
    default : {
      fail("Unknown init system ${init_system}, unable to install startup script for Yas3fs")
    }
  }

  if $ensure == 'present' or $ensure == 'mounted' or $ensure == 'unmounted' {
    service { "s3fs-${name}":
      ensure  => $service_ensure,
      enable  => $service_enable,
      require => [
        File["yas3fs-${name}"],
      ]
    }
  }

}
