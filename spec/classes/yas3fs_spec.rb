require 'spec_helper'
describe 'yas3fs', type: :class do

  context 'on a supported operating system' do
    on_supported_os.each do |os, facts|
      context os do
        let(:facts) do
          facts
        end

        context 'defaults' do
          it { is_expected.to contain_package('fuse') }
          # This case statement currently does not work running pdk test unit
          # I think it has something to newer facter/facterdb gem
          # attempting to run facterdb locally complains of switching
          # from get_os_facts to get_facts.
          case facts[:osfamily]
            when 'Redhat'
              it { is_expected.to contain_package('fuse-libs') }
          end
          it { is_expected.to contain_package('python-pip') }

          it {
            is_expected.to contain_augeas('fuse.conf:user_allow_other').with(
            'context' => '/files/etc/fuse.conf',
            'changes' => [
              'set user_allow_other ""',
            ],
          )
          }

          context 'with install_pip_package set to false' do
            let :params do
              {
                install_pip_package: false,
              }
            end

            it { is_expected.not_to contain_package('python-pip') }
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
      end
    end
  end
end
