# yas3fs package install
class yas3fs::package {
  assert_private()

  if $::yas3fs::install_pip_package {
    package { 'python-pip':
      ensure        => present,
      allow_virtual => true
    }
  }

  package { 'fuse':
    ensure        => present,
    allow_virtual => true
  }

  if ($::osfamily == 'RedHat') {
    package { 'fuse-libs':
      ensure        => present,
      allow_virtual => true
    }
  }

  package { 'yas3fs':
    ensure        => present,
    provider      => 'pip',
    allow_virtual => true
  }

}
