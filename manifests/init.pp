# A module to manage S3 mounts using yas3fs
class yas3fs (
  $install_pip_package = $yas3fs::params::install_pip_package,
  $init_system         = $yas3fs::params::init_system,
  $mounts              = {},
) inherits yas3fs::params {

  anchor { 'yas3fs::begin': } ->
  class { '::yas3fs::package': } ->
  class { '::yas3fs::config': } ->
  anchor { 'yas3fs::end':}

  if !empty($mounts) {
    create_resources('yas3fs::mount', $mounts)
  }

}
