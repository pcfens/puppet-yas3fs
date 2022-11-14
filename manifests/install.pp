# yas3fs package install
# 
# Class parameters are defined in init.pp
# Please check init.pp for usage.
# Please set parameters in base class (init.pp)
#
class yas3fs::install (
  $manage_python       = $::yas3fs::manage_python,
  $manage_requirements = $::yas3fs::manage_requirements,
  $python_version      = $::yas3fs::python_version,
  $vcs_remote          = $::yas3fs::vcs_remote,
  $vcs_revision        = $::yas3fs::vcs_revision,
  $venv_path           = $::yas3fs::venv_path,
){
  assert_private()


  # python::pyvenv includes python class
  # so if we do not want python to be managed/touched
  # in any way manage_python should be set to false
  if !defined(Class['python']) {
    class { 'python':
      version               => $python_version,
      manage_python_package => $manage_python,
      manage_pip_package    => $manage_python,
    }
  }

  # pyenv needs major and minor version number
  # borrow code trick
  # from https://github.com/voxpupuli/puppet-python/blob/v6.2.1/manifests/pyvenv.pp#L39-L42
  # python3_version and python2_version are facts created by python module
  $_python_version = $python_version ? {
    '3' => $facts['python3_version'],
    '2' => $facts['python2_version'],
    default  => $python_version,
  }

  if ($venv_path != '') {
    if versioncmp($python_version, '3') <0 {
      fail( "Virtual environment can only be used with python3+, please set venv_path to '' for use with python2")
    }

    # Create all parent directories in provided $venv_path
    # https://stackoverflow.com/a/56909439
    $venv_path_dirs = $venv_path[1,-1].dirname.split('/').reduce([]) |$memo, $subdir| {
    $_dir =  $memo.empty ? {
        true    => "/${subdir}",
        default => "${$memo[-1]}/${subdir}",
    }
    concat($memo, $_dir)
    }
    file {$venv_path_dirs:
        ensure => directory,
    }

    python::pyvenv { 'yas3fs virtual environment' :
      ensure     => present,
      version    => $_python_version,
      systempkgs => false,
      venv_dir   => $venv_path,
      before     => Exec['install yas3fs'],
    }
  }

  if ! defined(Package['fuse']) {
    package { 'fuse':
      ensure        => present,
      allow_virtual => true
    }
  }

  if ($facts['os']['family'] == 'RedHat') {
    if ! defined(Package['fuse-libs']) {
      package { 'fuse-libs':
        ensure        => present,
        allow_virtual => true
      }
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
  # we will use python::requirements to ensure
  # yas3fs requirements are installed.

  $virtualenv = $venv_path ? {
    '' => undef,
    default => $venv_path,
  }

  if ($manage_requirements == true) {
    file { '/root/yas3fs_requirements.txt' :
      ensure  => present,
      content => file('yas3fs/requirements.txt'),
      owner   => 'root',
      group   => 'root',
      mode    => '0664',
      notify  => Python::Requirements['/root/yas3fs_requirements.txt']
    }
    python::requirements { '/root/yas3fs_requirements.txt' :
      virtualenv => $virtualenv,
      require    => File['/root/yas3fs_requirements.txt'],
      before     => Exec['install yas3fs'],
    }
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
  if $venv_path != '' {
    $_exec_command = "source ${venv_path}/bin/activate && python${python_version} /var/tmp/yas3fs/setup.py install --prefix=${venv_path}"
    $_exec_creates = "${venv_path}/bin/yas3fs"
  }else{
    $_exec_command = "/usr/bin/env python${python_version} /var/tmp/yas3fs/setup.py install"
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
    onlyif      => "test -f ${_exec_creates}",
    notify      => Exec['install yas3fs'],
  }

  exec { 'install yas3fs':
    command  => $_exec_command,
    creates  => $_exec_creates,
    cwd      => '/var/tmp/yas3fs',
    provider => 'shell',
    require  => Vcsrepo['/var/tmp/yas3fs'],
  }
}
