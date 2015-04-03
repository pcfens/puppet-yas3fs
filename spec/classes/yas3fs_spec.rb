require 'spec_helper'
describe 'yas3fs', :type => :class do

  context 'defaults' do
    it { is_expected.to contain_yas3fs__params }
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
  end
end
