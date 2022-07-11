# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include yas3fs::python
class yas3fs::python (
  $python_version = $::yas3fs::python_version,
) {

  class { 'python':
    version => $python_version,
    pip     => 'present',
  }

}
