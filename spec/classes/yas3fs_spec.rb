require 'spec_helper'
describe 'yas3fs', type: :class do
  context 'on a supported operating system' do
    on_supported_os.each do |os, facts|
      context os do
        let(:facts) do
          facts.merge({
                        python3_version: '3.6',
            python2_version: '2.7',

                      })
        end

        context 'with defaults' do
          describe 'Is expected to install/configure package dependencies and yas3fs' do
            it {
              is_expected.to contain_class('python').with(
                'version'               => '3',
                'manage_python_package' => false,
                'manage_pip_package'    => false,
              )
            }

            it {
              is_expected.not_to contain_python__pyenv('yas3fs virtual environment')
            }

            it { is_expected.to contain_package('fuse') }
            # This case statement currently does not work running pdk test unit
            # I think it has something to newer facter/facterdb gem
            # attempting to run facterdb locally complains of switching
            # from get_os_facts to get_facts.
            case facts[:os][:family]
            when 'Redhat'
              it do
                is_expected.to contain_package('fuse-libs')
              end
            end

            it {
              is_expected.to contain_augeas('fuse.conf:user_allow_other').with(
                'context' => '/files/etc/fuse.conf',
                'changes' => [
                  'set user_allow_other ""',
                ],
              )
            }

            case facts[:os][:family]
            when 'Redhat', 'Amazon'
              case facts[:os][:release][:major]
              when '6', '7'
                it {
                  is_expected.to contain_file('/root/yas3fs_requirements.txt').with(
                    'ensure'  => 'present',
                    'owner'   => 'root',
                    'group'   => 'root',
                    'mode'    => '0664',
                  )
                }

                it {
                  is_expected.to contain_python__requirements('/root/yas3fs_requirements.txt').with(
                    'virtualenv' => '/opt/yas3fs/venv',
                    'require'    => 'File[/root/yas3fs_requirements.txt]',
                    'before'     => 'Exec[install yas3fs]',
                  )
                }
              end
            end

            it {
              is_expected.to contain_vcsrepo('/var/tmp/yas3fs').with(
                'ensure'   => 'present',
                'provider' => 'git',
                'source'   => 'https://github.com/danilop/yas3fs.git',
                'revision' => '5bbf8296b5cb16c8afecad94ea55d03c4052a683',
              )
            }

            it {
              is_expected.to contain_exec('remove install yas3fs creates file').with(
                'refreshonly' => true,
                'command'     => '/usr/bin/rm /opt/yas3fs/venv/bin/yas3fs',
                'subscribe'   => 'Vcsrepo[/var/tmp/yas3fs]',
                'notify'      => 'Exec[install yas3fs]',
              )
            }
            it {
              is_expected.to contain_exec('install yas3fs').with(
                'command' => 'source /opt/yas3fs/venv/bin/activate && python3 /var/tmp/yas3fs/setup.py install --prefix=/opt/yas3fs/venv',
                'creates' => '/opt/yas3fs/venv/bin/yas3fs',
                'cwd'     => '/var/tmp/yas3fs',
                'require' => 'Vcsrepo[/var/tmp/yas3fs]',
              )
            }
          end

          context 'with mounts in the initial resource creation' do
            let :params do
              {
                mounts: {
                  'test-mount' => {
                    's3_url'     => 's3://example-bucket/',
                    'local_path' => '/media/s3',
                  }
                }
              }
            end

            it {
              is_expected.to contain_file('yas3fs-test-mount').with(
              'ensure' => 'present',
              'path'   => '/etc/init/s3fs-test-mount.conf',
            )
            }

            it {
              is_expected.to contain_service('s3fs-test-mount').with(
              'ensure' => 'running',
              'enable' => true,
            )
            }
          end
        end

        context 'with venv_path set to \'\'' do
          let(:params) do
            {
              'venv_path' => '',
            }
          end

          case facts[:os][:family]
          when 'Redhat', 'Amazon'
            case facts[:os][:release][:major]
            when '6', '7'
              it {
                is_expected.to contain_python__requirements('/root/yas3fs_requirements.txt').with(
                  'virtualenv' => 'system',
                  'require'    => 'File[/root/yas3fs_requirements.txt]',
                  'before'     => 'Exec[install yas3fs]',
                )
              }
            end
          end
          it {
            is_expected.to contain_exec('remove install yas3fs creates file').with(
              'refreshonly' => true,
              'command'     => '/usr/bin/rm /usr/local/bin/yas3fs',
              'subscribe'   => 'Vcsrepo[/var/tmp/yas3fs]',
              'notify'      => 'Exec[install yas3fs]',
            )
          }
          it {
            is_expected.to contain_exec('install yas3fs').with(
              'command' => '/usr/bin/env python3 /var/tmp/yas3fs/setup.py install',
              'creates' => '/usr/local/bin/yas3fs',
              'cwd'     => '/var/tmp/yas3fs',
              'require' => 'Vcsrepo[/var/tmp/yas3fs]',
            )
          }
        end

        context 'with manage_python set to true' do
          let(:params) do
            {
              'manage_python' => true,
            }
          end

          it {
            is_expected.to contain_class('python').with(
              'version'               => '3',
              'manage_python_package' => true,
              'manage_pip_package'    => true,
            )
          }
        end

        context 'with manage_requirements set to false' do
          let(:params) do
            {
              'manage_requirements' => false,
            }
          end

          it {
            is_expected.not_to contain_python__requirements('/root/yas3fs_requirements.txt')
          }
        end

        context 'with python_version  = 2' do
          let(:params) do
            {
              'python_version' => '2',
            }
          end

          it {
            is_expected.to contain_class('python').with(
              'version'               => '2',
              'manage_python_package' => false,
              'manage_pip_package'    => false,
            )
          }
          it {
            is_expected.to contain_exec('install yas3fs').with(
              'command' => 'source /opt/yas3fs/venv/bin/activate && python2 /var/tmp/yas3fs/setup.py install --prefix=/opt/yas3fs/venv',
              'creates' => '/opt/yas3fs/venv/bin/yas3fs',
              'cwd'     => '/var/tmp/yas3fs',
              'require' => 'Vcsrepo[/var/tmp/yas3fs]',
            )
          }
        end

        context 'with python_version = 2.7' do
          let(:params) do
            {
              'python_version' => '2.7',
            }
          end

          it {
            is_expected.to contain_class('python').with(
              'version'               => '2.7',
              'manage_python_package' => false,
              'manage_pip_package'    => false,
            )
          }
          it {
            is_expected.to contain_exec('install yas3fs').with(
              'command' => 'source /opt/yas3fs/venv/bin/activate && python2.7 /var/tmp/yas3fs/setup.py install --prefix=/opt/yas3fs/venv',
              'creates' => '/opt/yas3fs/venv/bin/yas3fs',
              'cwd'     => '/var/tmp/yas3fs',
              'require' => 'Vcsrepo[/var/tmp/yas3fs]',
            )
          }
        end

        context 'with python_version = python3' do
          let(:params) do
            {
              'python_version' => '3',
            }
          end

          it {
            is_expected.to contain_class('python').with(
              'version'               => '3',
              'manage_python_package' => false,
              'manage_pip_package'    => false,
            )
          }
          it {
            is_expected.to contain_exec('install yas3fs').with(
              'command' => 'source /opt/yas3fs/venv/bin/activate && python3 /var/tmp/yas3fs/setup.py install --prefix=/opt/yas3fs/venv',
              'creates' => '/opt/yas3fs/venv/bin/yas3fs',
              'cwd'     => '/var/tmp/yas3fs',
              'require' => 'Vcsrepo[/var/tmp/yas3fs]',
            )
          }
        end

        context 'with python_version = 3.6' do
          let(:params) do
            {
              'python_version' => '3.6',
            }
          end

          it {
            is_expected.to contain_class('python').with(
              'version'               => '3.6',
              'manage_python_package' => false,
              'manage_pip_package'    => false,
            )
          }
          it {
            is_expected.to contain_exec('install yas3fs').with(
              'command' => 'source /opt/yas3fs/venv/bin/activate && python3.6 /var/tmp/yas3fs/setup.py install --prefix=/opt/yas3fs/venv',
              'creates' => '/opt/yas3fs/venv/bin/yas3fs',
              'cwd'     => '/var/tmp/yas3fs',
              'require' => 'Vcsrepo[/var/tmp/yas3fs]',
            )
          }
        end
      end
    end
  end
end
