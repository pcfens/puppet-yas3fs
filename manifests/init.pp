# A module to manage S3 mounts using yas3fs
class yas3fs (
  $install_pip_package          = $::yas3fs::params::install_pip_package,
  $init_system                  = $::yas3fs::params::init_system,
  $mounts                       = {},
  $python_version               = 'python3', # Versions such as python,python2.7,python3,python3.6
  $vcs_remote                   = $::yas3fs::params::vcs_remote,
  $vcs_revision                 = $::yas3fs::params::vcs_revision,
  $venv_path                    = $::yas3fs::params::venv_path, #Path to install python virtual environment
) inherits yas3fs::params {

  anchor { 'yas3fs::begin': }
  -> class { '::yas3fs::package': }
  -> class { '::yas3fs::config': }
  -> anchor { 'yas3fs::end':}

  if !empty($mounts) {
    create_resources('yas3fs::mount', $mounts)
  }

}
