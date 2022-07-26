# yas3fs package install
class yas3fs::install (
  $manage_python  = $::yas3fs::manage_python,
  $python_version = $::yas3fs::python_version,
  $vcs_remote     = $::yas3fs::vcs_remote,
  $vcs_revision   = $::yas3fs::vcs_revision,
  $venv_path      = $::yas3fs::venv_path,
){
  assert_private()


  if ($manage_python == true) {
    class { 'python':
      version => $python_version,
      pip     => 'present',
    }
  }

  if $venv_path {
    python::pyvenv { 'yas3fs virtual environment' :
      ensure     => present,
      version    => $python_version,
      systempkgs => false,
      venv_dir   => $venv_path,
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
    ensure        => '44.0.0',
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


  # TODO offer better cleanup, and remove yas3fs via pip
  # before install yas3fs overtop of previous version

  #If Virtual Environment created pythin should be symlinked to $python_version
  if $venv_path {
    $_exec_command = ". ${venv_path}/bin/activate && ${python_version} /var/tmp/yas3fs/setup.py install --prefix=${venv_path}"
    $_exec_creates = "${venv_path}/bin/yas3fs"
  }else{
    $_exec_command = "/usr/bin/env ${python_version} /var/tmp/yas3fs/setup.py install"
    # Newer python setup tools installs to /usr/local/bin/ ???
    # Users which install does not create /usr/local/bin/yasfs consider making a symlink to
    # Wherever it got installed so puppet will not attempt to reinstall every run
    # I can really only test on a Redhat machine and relay on rspec to test everything else
    # - Ron (mojibake-umd) -
    $_exec_creates = '/usr/local/bin/yas3fs'
  }

  # Trigger install of yas3fs on vcsrepo refresh
  exec { 'remove install yas3fs creates file':
    refreshonly => true,
    command     => "/usr/bin/rm ${_exec_creates}",
    subscribe   => Vcsrepo['/var/tmp/yas3fs'],
    notify      => Exec['install yas3fs'],
  }

  exec { 'install yas3fs':
    command => $_exec_command,
    creates => $_exec_creates,
    cwd     => '/var/tmp/yas3fs',
    require => Vcsrepo['/var/tmp/yas3fs'],
  }
}
