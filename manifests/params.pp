# yas3fs defaults
class yas3fs::params {

  $manage_requirements = true

  if ($facts['service_provider']) {
    $init_system = $facts['service_provider']
  } else {
    $init_system = 'upstart'
  }

}
