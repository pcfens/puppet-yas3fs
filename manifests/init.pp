# A module to manage S3 mounts using yas3fs
class yas3fs (
  $init_system                  = $::yas3fs::params::init_system,
  $mounts                       = {},
  $python_version               = 'python3', # Versions such as python,python2.7,python3,python3.6
  $vcs_remote                   = 'https://github.com/danilop/yas3fs.git',
  $vcs_revision                 = 'master',
  $venv_path                    = undef, #Path to install python virtual environment
) inherits yas3fs::params {

  anchor { 'yas3fs::begin': }
  -> class { '::yas3fs::package': }
  -> class { '::yas3fs::config': }
  -> anchor { 'yas3fs::end':}

  if !empty($mounts) {
    create_resources('yas3fs::mount', $mounts)
  }

}
