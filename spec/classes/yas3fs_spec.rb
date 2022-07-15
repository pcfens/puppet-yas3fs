require 'spec_helper'
describe 'yas3fs', type: :class do
  context 'on a supported operating system' do
    on_supported_os.each do |os, facts|
      context os do
        let(:facts) do
          facts
        end

        context 'with defaults' do
          describe 'Is expected to install/configure package dependencies and yas3fs' do
            it { is_expected.to contain_package('fuse') }
            # This case statement currently does not work running pdk test unit
            # I think it has something to newer facter/facterdb gem
            # attempting to run facterdb locally complains of switching
            # from get_os_facts to get_facts.
            case facts[:osfamily]
            when 'Redhat'
              it { is_expected.to contain_package('fuse-libs') }
            end

            it {
              is_expected.to contain_augeas('fuse.conf:user_allow_other').with(
                'context' => '/files/etc/fuse.conf',
                'changes' => [
                  'set user_allow_other ""',
                ],
              )
            }

            it {
              is_expected.to contain_vcsrepo('/var/tmp/yas3fs').with(
                'ensure'   => 'present',
                'provider' => 'git',
                'source'   => 'https://github.com/danilop/yas3fs.git',
                'revision' => 'master',
              )
            }
            it {
              is_expected.to contain_exec('install yas3fs').with(
                'command' => '/usr/bin/env python3 /var/tmp/yas3fs/setup.py install',
                'creates' => '/usr/bin/yas3fs',
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
          context 'with venv_path set to /opt/yas3fs/venv' do
            let(:params) do
              {
                'venv_path' => '/opt/yas3fs/venv'
              }
            end

            it {
              is_expected.to contain_exec('install yas3fs').with(
                'command' => '. /opt/yas3fs/venv/bin/activate && python3 /var/tmp/yas3fs/setup.py install --prefix=/opt/yas3fs/venv',
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
end
