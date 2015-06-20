# yas3fs defaults
class yas3fs::params {
  $install_pip_package = true
  $install_init        = $::initsystem

  # Compatibility mode for existing users, if missing the jethrocarr-initfact
  # module, we fall back to using the upstart init script/configuration.
  if (!$install_init) {
    $install_init = 'upstart'
  }
}
