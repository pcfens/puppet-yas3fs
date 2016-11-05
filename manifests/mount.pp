# A yas3fs mount
define yas3fs::mount (
  $s3_url,
  $local_path,
  $ensure                = 'mounted',
  $options               = [],
  $aws_access_key_id     = undef,
  $aws_secret_access_key = undef,
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

  case $yas3fs::init_system {
    'systemd': {
      exec { "yas3fs_reload_systemd-${name}":
        # SystemD needs a reload after any unit file change
        command     => 'systemctl daemon-reload',
        path        => ['/bin', '/sbin', '/usr/bin', '/usr/sbin'],
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
      fail("Unknown init system ${yas3fs::init_system}, unable to install startup script for Yas3fs")
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
