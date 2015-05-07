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

  contain ::yas3fs

  file { $local_path:
    ensure => directory,
  }

  case $ensure {
    'mounted': {
      $upstart_file_ensure = 'present'
      $service_ensure = 'running'
      $service_enable = true
    }
    'unmounted': {
      $upstart_file_ensure = 'present'
      $service_ensure = 'stopped'
      $service_enable = false
    }
    'present': {
      $upstart_file_ensure = 'present'
      $service_ensure = 'running'
      $service_enable = true
    }
    'absent': {
      $upstart_file_ensure = 'absent'
    }
    default: {
      fail('Only mounted, unmounted, and present are valid ensure values for yas3fs::mount')
    }
  }

  file { "yas3fs-${name}.conf":
    ensure  => $upstart_file_ensure,
    path    => "/etc/init/s3fs-${name}.conf",
    content => template('yas3fs/upstart.erb'),
    owner   => 'root',
    group   => 'root',
    notify  => Service["s3fs-${name}"],
  }

  if $ensure == 'present' or $ensure == 'mounted' or $ensure == 'unmounted' {
    service { "s3fs-${name}":
      ensure  => $service_ensure,
      enable  => $service_enable,
      require => [
        File["yas3fs-${name}.conf"],
        Class['yas3fs'],
      ]
    }
  }

}
