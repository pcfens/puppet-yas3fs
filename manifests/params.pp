# yas3fs defaults
class yas3fs::params {

  if ($facts['service_provider']) {
    $init_system = $facts['service_provider']
  } else {
    $init_system = 'upstart'
  }

  case $facts['os']['family'] {
    'RedHat', 'Amazon': {
      case $facts['os']['release']['major'] {
        '7', '6': {
          $manage_requirements = true
        }
        default: {
          $manage_requirements = false
        }
      }
    }
    default: {
      $manage_requirements = false
    }
  }
}
