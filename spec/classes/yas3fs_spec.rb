require 'spec_helper'
describe 'yas3fs', :type => :class do

  let :facts do {
    :osfamily => 'Debian',
    :initsystem => 'upstart'
  } end


  context 'defaults' do
    it { is_expected.to contain_package('fuse') }
    it { is_expected.to contain_package('python-pip') }

    it { is_expected.to contain_augeas('fuse.conf:user_allow_other').with(
      'context' => '/files/etc/fuse.conf',
      'changes' => [
        'set user_allow_other ""',
      ]
    ) }

    context 'with install_pip_package set to false' do
      let :params do
        {
          :install_pip_package => false,
        }
      end

      it { is_expected.not_to contain_package('python-pip')}

    end

    context 'with mounts in the initial resource creation' do
      let :params do
        {
          :mounts => {
            'test-mount' => {
              's3_url'     => 's3://example-bucket/',
              'local_path' => '/media/s3',
            }
          }
        }
      end

      it { is_expected.to contain_file('yas3fs-test-mount').with(
        'ensure' => 'present',
        'path'   => '/etc/init/s3fs-test-mount.conf',
      ) }

      it { is_expected.to contain_service('s3fs-test-mount').with(
        'ensure' => 'running',
        'enable' => true,
      ) }


    end

  end
end
