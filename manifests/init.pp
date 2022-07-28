# A module to manage S3 mounts using yas3fs
# @venv_path:
# If set to '' system python library path will be used
class yas3fs (
  $init_system         = $::yas3fs::params::init_system,
  $manage_python       = true,
  $manage_requirements = true,
  $mounts              = {},
  $python_version      = 'python3', # Versions such as python,python2.7,python3,python3.6
  $vcs_remote          = 'https://github.com/danilop/yas3fs.git',
  $vcs_revision        = '5bbf8296b5cb16c8afecad94ea55d03c4052a683', # v2.4.6 No tag available
  $venv_path           = '/opt/yas3fs/venv', #Path to install python virtual environment
) inherits yas3fs::params {

  anchor { 'yas3fs::begin': }
  -> class { '::yas3fs::install': }
  -> class { '::yas3fs::config': }
  -> anchor { 'yas3fs::end':}

  if !empty($mounts) {
    create_resources('yas3fs::mount', $mounts)
  }

}
