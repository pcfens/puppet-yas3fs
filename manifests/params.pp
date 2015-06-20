# yas3fs defaults
class yas3fs::params {
  $install_pip_package = true


  # Use the jethrocarr-initfact module to determine which init system is in
  # use, fall back to using upstart if missing to ensure compatibility with
  # exiting puppet-yas3fs users.

  if ($::initsystem) {
    $install_init = $::initsystem
  } else {
    $install_init = 'upstart'
  }

}
