# yas3fs package install
class yas3fs::package (
  $provider     = $yas3fs::provider,
  $vcs_remote   = $yas3fs::vcs_remote,
  $vcs_revision = $yas3fs::vcs_revision,
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

  case $provider {
    'pip': {
      package { 'yas3fs':
        ensure        => present,
        provider      => 'pip',
        allow_virtual => true
      }
    }
    'vcs': {
      vcsrepo { '/var/tmp/yas3fs':
        # Just 'present' so we do not beatup our git repository
        # provider every 30mins
        ensure   => present,
        provider => git,
        source   => $vcs_remote,
        revision => $vcs_revision,
      }

      exec { 'install yas3fs':
        command => 'python setup.py install',
        creates => '/usr/bin/yas3fs',
        require => Vcsrepo['/var/tmp/yas3fs'],
      }
    }
    default: {
      package { 'yas3fs':
        ensure        => present,
        provider      => 'pip',
        allow_virtual => true
      }
    }
  }
}
