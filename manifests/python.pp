# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include yas3fs::python
class yas3fs::python (
  $python_version = $::yas3fs::python_version,
  $venv_path      = $::yas3fs::venv_path,
) {


  if $venv_path {
    python::pyvenv { 'yas3fs virtual environment' :
      ensure     => present,
      version    => 'system',
      systempkgs => false,
      venv_dir   => $venv_path,
    }
  }

}
