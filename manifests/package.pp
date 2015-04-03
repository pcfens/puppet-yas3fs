# yas3fs package install
class yas3fs::package {
  assert_private()

  if $::yas3fs::install_pip_package {
    package { 'python-pip':
      ensure => present,
    }
  }

  package { 'fuse':
    ensure => present,
  }

  package { 'yas3fs':
    ensure   => present,
    provider => 'pip',
  }

}
