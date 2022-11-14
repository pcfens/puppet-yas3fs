# A module to manage S3 mounts using yas3fs
# * `init_system`:
#   Specify the init system used. i.g. sysv, systemd
#
# * `manage_python`:
#   Should this module attempt to install and manage
#   python?
#
# * `manage_requirements`:
#   Should this module attempt to install and manage
#   yas3fs dependencies?
#
# * `mounts`:
#   A hash of mounts and mount options passed to
#   defined type yas3fs::mount
#
# * `python_version`:
#   Which version /usr/bin/pythonX[.Y] should be
#   used to run yas3fs?
#
# * `vcsrepo`:
#   The VCS repository to fetch yas3fs code.
#
# * `vcs_revision`:
#   Revision/Commit/Branch/Tag to check out
#   when installing yas3fs
#
# * `venv_path`:
#   If set to '' system python library path will be used.
#   Highly recommend installing yas3fs to a virtual environment
#   to avoid causing issues with your python based package
#   management systems i.g. apt, yum...
#
class yas3fs (
  $init_system         = $::yas3fs::params::init_system,
  $manage_python       = false,
  $manage_requirements = true,
  $mounts              = {},
  $python_version      = '3', # Versions 2,2.7,3,3.6
  $vcs_remote          = 'https://github.com/danilop/yas3fs.git',
  $vcs_revision        = '5bbf8296b5cb16c8afecad94ea55d03c4052a683', # v2.4.6 No tag available
  $venv_path           = '/opt/yas3fs/venv', #Path to install python virtual environment
) inherits yas3fs::params {

  anchor { 'yas3fs::begin': }
  -> class { '::yas3fs::install': }
  -> class { '::yas3fs::config': }
  -> anchor { 'yas3fs::end':}

  if !empty($mounts) {
    create_resources('yas3fs::mount', $mounts)
  }

}
