# yas3fs defaults
class yas3fs::params {
  $install_pip_package = true
  $provider = 'pip'
  $vcs_remote = 'https://github.com/danilop/yas3fs.git'
  $vcs_revision = 'master'

  if ($facts['service_provider']) {
    $init_system = $facts['service_provider']
  } else {
    $init_system = 'upstart'
  }

}
