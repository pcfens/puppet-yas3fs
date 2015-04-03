# yas3fs configuration
class yas3fs::config {
  assert_private()

  file { '/etc/fuse.conf':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0664',
  }

  augeas { 'fuse.conf:user_allow_other':
    context => '/files/etc/fuse.conf',
    changes => [
      'set user_allow_other ""',
    ]
  }
}
