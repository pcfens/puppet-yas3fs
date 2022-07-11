# yas3fs package install
class yas3fs::package (
  $vcs_remote   = $::yas3fs::vcs_remote,
  $vcs_revision = $::yas3fs::vcs_revision,
){
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

  # Unfortunately puppet package resource does not allow us to
  # Uninstall a specific version of a pip package.
  # Attempting to set ensure absent for pip package yas3fs
  # Will also uninstall the version installed from source.
  # Attempting to set ensure latest also does not work well.
  # Please manually uninstall yas3fs pip package if going
  # from pip package to install from source.

  # On Redhat 7
  # yum installed python-setuptools is 0.9.8
  # can not uninstall python-setuptools due to dependencies,
  # but can let pip try to install a newer version overtop
  # howver not recommended, use virtual environment instead.
  # yas3fs setup.py barfs on setuptools and boto3 installs.
  # Let setup.py handle the rest of the requirements
  package { 'setuptools':
    ensure        => '2.2',
    provider      => 'pip',
    allow_virtual => true,
    notify        => Exec['install yas3fs'],
  }
  vcsrepo { '/var/tmp/yas3fs':
    # Just 'present' so we do not beatup our git repository
    # provider every 30mins
    ensure   => present,
    provider => git,
    source   => $vcs_remote,
    revision => $vcs_revision,
  }

  exec { 'install yas3fs':
    command => 'python /var/tmp/yas3fs/setup.py install',
    creates => '/usr/bin/yas3fs',
    cwd     => '/var/tmp/yas3fs',
    require => Vcsrepo['/var/tmp/yas3fs'],
  }
}
