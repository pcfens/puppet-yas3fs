# A module to manage S3 mounts using yas3fs
class yas3fs (
  $install_pip_package = $yas3fs::params::install_pip_package,
  $install_init        = $yas3fs::params::install_init,
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
