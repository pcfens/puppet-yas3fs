# yas3fs defaults
class yas3fs::params {
  $install_pip_package = true
  $provider = 'pip'
  $vcs_remote = 'https://github.com/danilop/yas3fs.git'
  $vcs_revision = 'master'

  # Use the jethrocarr-initfact module to determine which init system is in
  # use, fall back to using upstart if missing to ensure compatibility with
  # exiting puppet-yas3fs users.

  if ($::initsystem) {
    $init_system = $::initsystem
  } else {
    $init_system = 'upstart'
  }

}
